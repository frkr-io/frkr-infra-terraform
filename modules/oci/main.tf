# OCI Module - Thin wrapper around ystory/always-free-oke

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }
  }
}

module "oke_free" {
  source  = "ystory/always-free-oke/oci"
  version = "~> 1.0"

  tenancy_id           = var.tenancy_id
  home_region          = var.home_region
  region               = var.region
  node_pool_size       = var.node_pool_size
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path

  providers = {
    oci.home = oci.home
  }
}
