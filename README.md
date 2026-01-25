# frkr-infra-terraform

Infrastructure as Code for provisioning Kubernetes clusters to run [frkr](https://github.com/frkr-io/frkr-tools).

## Overview

This repository provides Terraform modules and presets for provisioning Kubernetes clusters across multiple cloud providers. It follows a composable architecture that leverages existing open-source Terraform modules.

## Repository Structure

```
frkr-infra-terraform/
├── modules/           # Thin wrappers around external modules
│   ├── oci/          # OCI (Oracle Cloud) module
│   ├── aws/          # AWS EKS module (future)
│   └── gcp/          # GCP GKE module (future)
├── presets/          # Ready-to-use configurations
│   ├── oci-free-tier/    # OCI Always Free tier setup
│   └── kind-local/       # Local Kind cluster (testing)
├── examples/         # Usage examples
└── scripts/          # Verification and helper scripts
```

## Quick Start: OCI Free Tier

Deploy a Kubernetes cluster on OCI's Always Free tier:

```bash
cd presets/oci-free-tier
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCI credentials

terraform init
terraform apply

# Verify free tier compliance
../scripts/verify-oci-free-tier.sh

# Export kubeconfig
export KUBECONFIG=$(terraform output -raw kubeconfig_path)
kubectl cluster-info
```

## Supported Providers

| Provider | Module | Free Tier? | Status |
|----------|--------|------------|--------|
| OCI | [`ystory/always-free-oke`](https://registry.terraform.io/modules/ystory/always-free-oke/oci) | ✅ Yes | Available |
| AWS | [`terraform-aws-modules/eks`](https://github.com/terraform-aws-modules/terraform-aws-eks) | ❌ No (~$70/mo) | Planned |
| GCP | [`terraform-google-modules/kubernetes-engine`](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine) | ⚠️ Partial | Planned |

## After Cluster Provisioning

Once your cluster is ready, deploy frkr using `frkrup`:

```bash
cd /path/to/frkr-tools
./bin/frkrup --config examples/config-oci.yaml
```

## License

Apache 2.0
