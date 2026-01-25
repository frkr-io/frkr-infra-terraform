# GCP GKE Module (Planned)

This module will provision a GKE cluster on Google Cloud Platform.

> **Note**: GKE Autopilot has a free control plane, but you pay per pod resources.

## Planned Implementation

Will wrap [`terraform-google-modules/kubernetes-engine`](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine).

```hcl
module "gcp_cluster" {
  source = "../../modules/gcp"
  
  project_id   = var.project_id
  cluster_name = "frkr-cluster"
  region       = "us-central1"
  autopilot    = true  # Recommended for cost efficiency
}
```
