output "kubeconfig" {
  description = "Kubeconfig content for the OKE cluster"
  value       = data.oci_containerengine_cluster_kube_config.default.content
  sensitive   = true
}

# kubeconfig_path is determined by the caller (preset), not this module.
# We remove it from here to avoid confusion/errors.

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = data.oci_containerengine_clusters.default.clusters[0].endpoints[0].public_endpoint
}
