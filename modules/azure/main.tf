terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

resource "azurerm_resource_group" "frkr_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = "Production"
    Project     = "frkr"
  }
}

resource "azurerm_kubernetes_cluster" "frkr_aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.frkr_rg.location
  resource_group_name = azurerm_resource_group.frkr_rg.name
  dns_prefix          = "frkr"

  # Standard SKU (Free Management). 'Paid' SKU offers Uptime SLA if needed.
  sku_tier = "Free"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
    
    # Cost Optimization: Smaller, Standard SSD disks
    os_disk_size_gb = var.os_disk_size_gb
    os_disk_type    = var.os_disk_type
    
    # Enable Auto-scaling optional, but fixed count is safer for budget

  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet" # Simpler than Azure CNI, saves IP address hassle
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "Production"
  }
}
