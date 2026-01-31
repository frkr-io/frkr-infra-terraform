variable "project_name" {
  description = "Name of the DigitalOcean project"
  type        = string
  default     = "frkr"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "frkr-cluster"
}

variable "region" {
  description = "DigitalOcean region slug (e.g., nyc1, sfo3)"
  type        = string
  default     = "nyc1"
}

variable "k8s_version" {
  description = "Kubernetes version slug"
  type        = string
  default     = "1.32.1-do.0"
}

variable "node_size" {
  description = "Droplet size slug (e.g., s-2vcpu-4gb)"
  type        = string
  default     = "s-2vcpu-4gb" # $12/mo each
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}
