# OCI Free Tier Preset

Ready-to-use configuration for deploying an OKE cluster on OCI's Always Free tier.

## Prerequisites

1. **OCI Account** with Free Tier eligibility
2. **OCI CLI** installed and configured (`oci setup config`)
3. **SSH Keypair** for node access

### Generate SSH Keys (if needed)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/oci-frkr -C "frkr-oci-cluster"
```

## Usage

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your OCI credentials:
   - Get your `tenancy_id` from OCI Console → Profile → Tenancy
   - Get your `region` from OCI Console (e.g., `us-phoenix-1`)
   - Set SSH key paths

3. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   
   # Verify free tier compliance before applying
   terraform plan -out=tfplan
   ../../scripts/verify-oci-free-tier.sh
   
   terraform apply tfplan
   ```

4. **Configure kubectl:**
   ```bash
   export KUBECONFIG=$(terraform output -raw kubeconfig_path)
   kubectl cluster-info
   ```

## Free Tier Compliance

This preset is configured to stay within OCI Always Free limits:

| Resource | Configuration | Free Limit |
|----------|--------------|------------|
| Node Shape | VM.Standard.A1.Flex | ✅ ARM64 (free) |
| Total OCPUs | 2 × 2 = 4 | 4 |
| Total Memory | 2 × 12GB = 24GB | 24GB |
| Boot Volume | 2 × 50GB = 100GB | 200GB |
| Load Balancer | 10Mbps Flexible | 10Mbps |

## Outputs

After `terraform apply`, you'll have:

- `kubeconfig_path` - Path to kubeconfig file
- `cluster_endpoint` - Kubernetes API URL
