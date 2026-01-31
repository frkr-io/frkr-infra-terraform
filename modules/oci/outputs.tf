# --- Outputs ---

# Generate Kubeconfig from the new cluster resource
data "oci_containerengine_cluster_kube_config" "frkr_kubeconfig" {
  cluster_id = oci_containerengine_cluster.frkr_k8s.id
}

output "kubeconfig" {
  description = "Kubeconfig content for the OKE cluster"
  value       = data.oci_containerengine_cluster_kube_config.frkr_kubeconfig.content
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = oci_containerengine_cluster.frkr_k8s.endpoints[0].public_endpoint
}

output "cluster_id" {
  description = "OCID of the OKE cluster"
  value       = oci_containerengine_cluster.frkr_k8s.id
}
