# AWS EKS Module (Planned)

This module will provision an EKS cluster on AWS.

> **Note**: AWS EKS does **not** have a free tier. The control plane costs ~$70/month.

## Planned Implementation

Will wrap [`terraform-aws-modules/eks`](https://github.com/terraform-aws-modules/terraform-aws-eks).

```hcl
module "aws_cluster" {
  source = "../../modules/aws"
  
  cluster_name      = "frkr-cluster"
  kubernetes_version = "1.29"
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  node_count        = 2
}
```
