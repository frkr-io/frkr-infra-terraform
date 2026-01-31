output "cluster_id" {
  description = "ID of the DOKS cluster"
  value       = digitalocean_kubernetes_cluster.frkr_cluster.id
}

output "cluster_endpoint" {
  description = "API Endpoint of the DOKS cluster"
  value       = digitalocean_kubernetes_cluster.frkr_cluster.endpoint
}

output "kubeconfig" {
  description = "Raw Kubeconfig"
  value       = digitalocean_kubernetes_cluster.frkr_cluster.kube_config[0].raw_config
  sensitive   = true
}

output "project_id" {
  description = "ID of the DigitalOcean Project"
  value       = digitalocean_project.frkr_project.id
}
