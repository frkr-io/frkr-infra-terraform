terraform {
  required_version = ">= 1.5.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.30.0"
    }
  }
}

variable "do_token" {
  description = "DigitalOcean Personal Access Token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region (nyc1, sfo3, etc.)"
  type        = string
  default     = "nyc1"
}

provider "digitalocean" {
  token = var.do_token
}

module "cluster" {
  source = "../../modules/digitalocean"

  region     = var.region
  node_count = 2
  node_size  = "s-2vcpu-4gb" # Cost: $24/mo ($12x2)
}

# Write kubeconfig to local file for easy access
resource "local_file" "kubeconfig" {
  content         = module.cluster.kubeconfig
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}
