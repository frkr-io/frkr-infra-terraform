# OCI Module - Thin wrapper around ystory/always-free-oke

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.123.0"
      configuration_aliases = [ oci.home ]
    }
  }
}

module "oke_free" {
  source  = "ystory/always-free-oke/oci"
  version = "0.0.16"

  tenancy_id           = var.tenancy_id
  home_region          = var.home_region
  region               = var.region
  node_pool_size       = var.node_pool_size
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  kubernetes_version   = "v1.31.1"

  providers = {
    oci.home = oci.home
  }
}

data "oci_containerengine_cluster_kube_config" "default" {
  cluster_id = module.oke_free.cluster_id
}

data "oci_containerengine_clusters" "default" {
  compartment_id = module.oke_free.compartment_id
  filter {
    name   = "id"
    values = [module.oke_free.cluster_id]
  }
}
