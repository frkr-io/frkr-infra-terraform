# OCI Free Tier Preset
# This preset provisions an OKE cluster optimized for OCI's Always Free tier

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.123.0"
    }
  }
}

# Provider configuration
provider "oci" {
  tenancy_ocid = var.tenancy_id
  region       = var.region
}

provider "oci" {
  alias        = "home"
  tenancy_ocid = var.tenancy_id
  region       = var.home_region
}

# Use the OCI module with free tier defaults
module "cluster" {
  source = "../../modules/oci"

  tenancy_id           = var.tenancy_id
  region               = var.region
  home_region          = var.home_region
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  node_pool_size       = 2  # 2 nodes × 2 OCPUs = 4 OCPUs (free tier max)

  providers = {
    oci.home = oci.home
  }
}

# Write kubeconfig to local file
resource "local_file" "kubeconfig" {
  content         = module.cluster.kubeconfig
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}
