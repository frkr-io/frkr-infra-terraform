# OCI Module

This module provisions an OKE (Oracle Kubernetes Engine) cluster on Oracle Cloud Infrastructure.

## Usage

This module wraps the [`ystory/always-free-oke`](https://registry.terraform.io/modules/ystory/always-free-oke/oci) module which is purpose-built for OCI's Always Free tier.

```hcl
module "oci_cluster" {
  source = "../../modules/oci"

  tenancy_id           = var.tenancy_id
  region               = var.region
  home_region          = var.home_region
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  node_pool_size       = 2
}
```

## Free Tier Limits

| Resource | Limit |
|----------|-------|
| Compute Shape | VM.Standard.A1.Flex (ARM64) |
| Total OCPUs | 4 |
| Total Memory | 24 GB |
| Boot Volume Storage | 200 GB |
| Load Balancer | 10 Mbps Flexible |

## Outputs

- `kubeconfig` - Kubeconfig content (sensitive)
- `kubeconfig_path` - Path to written kubeconfig file
- `cluster_endpoint` - Kubernetes API endpoint
