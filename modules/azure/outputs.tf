output "kube_config" {
  value     = azurerm_kubernetes_cluster.frkr_aks.kube_config_raw
  sensitive = true
}

output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.frkr_aks.kube_config[0].host
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.frkr_aks.name
}

output "resource_group_name" {
  value = azurerm_resource_group.frkr_rg.name
}
