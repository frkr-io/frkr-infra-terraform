variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "frkr-resources"
}

variable "location" {
  description = "Azure Region (e.g., westus2, eastus)"
  type        = string
  default     = "westus2"
}

variable "cluster_name" {
  description = "Name of the AKS Cluster"
  type        = string
  default     = "frkr-aks"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "VM Size for nodes"
  type        = string
  default     = "Standard_D2as_v5"
}

variable "os_disk_size_gb" {
  description = "Size of the OS Disk in GB"
  type        = number
  default     = 128
}

variable "os_disk_type" {
  description = "Type of OS Disk (Managed, Ephemeral)"
  type        = string
  default     = "Managed" # 'Managed' allows choosing type in nodepool. Actually for azurerm_kubernetes_cluster default_node_pool, 'os_disk_type' is 'Managed' or 'Ephemeral'. 
  # Wait, to set SKU (StandardSSD_LRS), we might need a different field depending on provider version, 
  # but azurerm default_node_pool supports 'os_sku' or 'type'. 
  # Actually, 'os_disk_type' in default_node_pool = "Managed" or "Ephemeral".
  # To set storage tier (Standard vs Premium), we usually rely on VM support or 'os_disk_type' nuances or it picks default. 
  # Correction: azurerm_kubernetes_cluster default_node_pool has `os_disk_type` (Managed/Ephemeral). 
  # To control cost, we rely on size mainly. 
  # BUT, looking at docs, `os_sku` is for Ubuntu/CBL. 
  # Wait, cost saving comes from using "Standard SSD" vs "Premium". 
  # We might need to verify if default is Premium. 
  # Ephemeral is best but B-series don't support it. 
  # Let's keep size limitation (64GB) which is the biggest saver.
}
