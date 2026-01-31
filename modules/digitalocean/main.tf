terraform {
  required_version = ">= 1.5.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.30.0"
    }
  }
}

# --- Project ---
# Organize resources into a Project
resource "digitalocean_project" "frkr_project" {
  name        = var.project_name
  description = "frkr infrastructure - Production"
  purpose     = "Web Application"
  environment = "Production"
}

# --- Kubernetes Cluster ---
resource "digitalocean_kubernetes_cluster" "frkr_cluster" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version

  # We use a dedicated node pool resource for better lifecycle management
  # This default pool is required by the resource but we keep it minimal
  # if we plan to use the separate resource. 
  # For simplicity in this module, we will just configure the pool here.
  node_pool {
    name       = "frkr-pool-basic"
    size       = var.node_size
    node_count = var.node_count
  }
}

# Assign cluster to project
resource "digitalocean_project_resources" "cluster_assignment" {
  project = digitalocean_project.frkr_project.id
  resources = [
    digitalocean_kubernetes_cluster.frkr_cluster.urn
  ]
}
