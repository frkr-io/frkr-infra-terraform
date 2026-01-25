output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.cluster.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = module.cluster.cluster_ca_certificate
  sensitive   = true
}
