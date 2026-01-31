terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "westus2"
}

module "cluster" {
  source = "../../modules/azure"

  location   = var.location
  node_count = 2
  node_size  = "Standard_B2s" # $36/mo/node. Safe for $150 budget.
  
  # Disk Optimization: Reduce to 64GB to save ~$30/mo
  os_disk_size_gb = 64
}

# Write kubeconfig to local file for easy access
resource "local_file" "kubeconfig" {
  content         = module.cluster.kube_config
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}
