variable "tenancy_id" {
  type        = string
  description = "OCI Tenancy OCID (get from OCI Console → Profile → Tenancy)"
}

variable "region" {
  type        = string
  description = "OCI region for resources (e.g., us-phoenix-1)"
}

variable "home_region" {
  type        = string
  description = "OCI home region for identity resources (usually same as region)"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key file (e.g., ~/.ssh/oci-frkr.pub)"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key file (e.g., ~/.ssh/oci-frkr)"
}
