output "kubeconfig" {
  description = "Kubeconfig content for the OKE cluster"
  value       = module.oke_free.kubeconfig
  sensitive   = true
}

output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file"
  value       = module.oke_free.kubeconfig_path
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.oke_free.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = module.oke_free.cluster_ca_certificate
  sensitive   = true
}
