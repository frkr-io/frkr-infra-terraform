terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}

# --- Data Sources ---

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

# Find the latest Oracle Linux 8 image for A1 (ARM)
data "oci_core_images" "oke_images" {
  compartment_id           = var.tenancy_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# --- Networking ---

resource "oci_core_vcn" "frkr_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.tenancy_id
  display_name   = "frkr-vcn"
  dns_label      = "frkr"
}

resource "oci_core_internet_gateway" "frkr_ig" {
  compartment_id = var.tenancy_id
  vcn_id         = oci_core_vcn.frkr_vcn.id
  display_name   = "frkr-ig"
  enabled        = true
}

resource "oci_core_route_table" "frkr_rt" {
  compartment_id = var.tenancy_id
  vcn_id         = oci_core_vcn.frkr_vcn.id
  display_name   = "frkr-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.frkr_ig.id
  }
}

resource "oci_core_security_list" "frkr_sl" {
  compartment_id = var.tenancy_id
  vcn_id         = oci_core_vcn.frkr_vcn.id
  display_name   = "frkr-public-sl"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow NodePort range (typical)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # ICMP
  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "frkr_service_subnet" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.tenancy_id
  vcn_id            = oci_core_vcn.frkr_vcn.id
  display_name      = "frkr-service-subnet"
  route_table_id    = oci_core_route_table.frkr_rt.id
  security_list_ids = [oci_core_security_list.frkr_sl.id]
}

resource "oci_core_subnet" "frkr_node_subnet" {
  cidr_block        = "10.0.10.0/24"
  compartment_id    = var.tenancy_id
  vcn_id            = oci_core_vcn.frkr_vcn.id
  display_name      = "frkr-node-subnet"
  route_table_id    = oci_core_route_table.frkr_rt.id
  security_list_ids = [oci_core_security_list.frkr_sl.id]
}

# --- OKE Cluster ---

resource "oci_containerengine_cluster" "frkr_k8s" {
  compartment_id     = var.tenancy_id
  kubernetes_version = "v1.31.1" # Hardcoded recent version as in old module
  name               = "frkr-cluster"
  vcn_id             = oci_core_vcn.frkr_vcn.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.frkr_service_subnet.id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [oci_core_subnet.frkr_service_subnet.id]
  }
}

# --- Node Pool (Free Tier Compliant) ---

resource "oci_containerengine_node_pool" "frkr_node_pool" {
  cluster_id         = oci_containerengine_cluster.frkr_k8s.id
  compartment_id     = var.tenancy_id
  kubernetes_version = oci_containerengine_cluster.frkr_k8s.kubernetes_version
  name               = "frkr-pool-arm"
  node_shape         = "VM.Standard.A1.Flex"
  
  node_config_details {
    size = var.node_pool_size

    # Iterate through all available ADs for placement
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.frkr_node_subnet.id
      }
    }
  }

  node_shape_config {
    # Free Tier Max: 4 OCPUs, 24GB RAM total.
    # We split this across 'var.node_pool_size' nodes (default 2).
    # 4 / 2 = 2 OCPUs
    # 24 / 2 = 12 GB RAM
    ocpus         = 2
    memory_in_gbs = 12
  }

  node_source_details {
    image_id    = data.oci_core_images.oke_images.images[0].id
    source_type = "IMAGE"
  }

  ssh_public_key = file(var.ssh_public_key_path)
}
