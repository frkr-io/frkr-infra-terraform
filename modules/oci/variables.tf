variable "tenancy_id" {
  type        = string
  description = "OCI Tenancy OCID"
}

variable "region" {
  type        = string
  description = "OCI region for resources (e.g., us-phoenix-1)"
}

variable "home_region" {
  type        = string
  description = "OCI home region for identity resources"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key file for node access"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key file (for bastion access)"
}

variable "node_pool_size" {
  type        = number
  description = "Number of worker nodes"
  default     = 2
}
