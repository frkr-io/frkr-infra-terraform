#!/bin/bash
# Verify OCI Terraform plan stays within Always Free limits
# Usage: terraform plan -out=tfplan && ./verify-oci-free-tier.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== OCI Free Tier Verification ==="

# Check if tfplan exists
if [ ! -f "tfplan" ]; then
    echo "Error: tfplan not found. Run 'terraform plan -out=tfplan' first."
    exit 1
fi

# Generate JSON plan
terraform show -json tfplan > tfplan.json

# Check 1: Node shape must be VM.Standard.A1.Flex (ARM, free tier)
echo "Checking node shape..."
NODE_SHAPE=$(jq -r '
  .planned_values.root_module.child_modules[]?.resources[]? 
  | select(.type=="oci_containerengine_node_pool") 
  | .values.node_shape // empty
' tfplan.json 2>/dev/null | head -1)

if [ -z "$NODE_SHAPE" ]; then
    echo "❌ Error: Could not determine node shape. logic may need update for this module structure."
    rm -f tfplan.json
    exit 1
elif [ "$NODE_SHAPE" != "VM.Standard.A1.Flex" ]; then
    echo "❌ Node shape '$NODE_SHAPE' is NOT Always Free (expected VM.Standard.A1.Flex)"
    rm -f tfplan.json
    exit 1
else
    echo "✅ Node shape: $NODE_SHAPE (Always Free)"
fi

# Check 2: Total OCPUs <= 4
echo "Checking OCPU allocation..."
OCPUS=$(jq -r '
  .planned_values.root_module.child_modules[]?.resources[]? 
  | select(.type=="oci_containerengine_node_pool") 
  | .values.node_shape_config.ocpus // empty
' tfplan.json 2>/dev/null | head -1)

NODE_COUNT=$(jq -r '
  .planned_values.root_module.child_modules[]?.resources[]? 
  | select(.type=="oci_containerengine_node_pool") 
  | .values.node_config_details.size // empty
' tfplan.json 2>/dev/null | head -1)

if [ -z "$OCPUS" ]; then
    echo "❌ Error: Could not determine OCPU count from plan."
    rm -f tfplan.json
    exit 1
fi

if [ -z "$NODE_COUNT" ]; then
    echo "❌ Error: Could not determine Node Count from plan."
    rm -f tfplan.json
    exit 1
fi

TOTAL_OCPUS=$((OCPUS * NODE_COUNT))

if [ "$TOTAL_OCPUS" -gt 4 ]; then
    echo "❌ Total OCPUs ($TOTAL_OCPUS) exceeds free tier limit (4)"
    rm -f tfplan.json
    exit 1
fi
echo "✅ Total OCPUs: $TOTAL_OCPUS / 4 (within free tier)"

# Check 3: Total memory <= 24GB
echo "Checking memory allocation..."
MEMORY_GB=$(jq -r '
  .planned_values.root_module.child_modules[]?.resources[]? 
  | select(.type=="oci_containerengine_node_pool") 
  | .values.node_shape_config.memory_in_gbs // empty
' tfplan.json 2>/dev/null | head -1)

if [ -z "$MEMORY_GB" ]; then
    echo "❌ Error: Could not determine Memory from plan."
    rm -f tfplan.json
    exit 1
fi

TOTAL_MEMORY=$((MEMORY_GB * NODE_COUNT))

if [ "$TOTAL_MEMORY" -gt 24 ]; then
    echo "❌ Total memory (${TOTAL_MEMORY}GB) exceeds free tier limit (24GB)"
    rm -f tfplan.json
    exit 1
fi
echo "✅ Total memory: ${TOTAL_MEMORY}GB / 24GB (within free tier)"

# Check 4: Boot volume <= 200GB total
echo "Checking storage allocation..."
BOOT_SIZE=$(jq -r '
  .planned_values.root_module.child_modules[]?.resources[]? 
  | select(.type=="oci_containerengine_node_pool") 
  | .values.node_source_details.boot_volume_size_in_gbs // empty
' tfplan.json 2>/dev/null | head -1)

if [ -z "$BOOT_SIZE" ]; then
    # It's possible for boot volume to be default if not specified in TF, but for this check we want to be explicit.
    # If the module defaults to 50, it should appear in planned_values. 
    # If it is null in plan, that implies "provider default", which we can't verify easily.
    # However, assuming "empty" here is risky. Let's error.
    echo "❌ Error: Could not determine Boot Volume size from plan."
    rm -f tfplan.json
    exit 1
fi

TOTAL_STORAGE=$((BOOT_SIZE * NODE_COUNT))

if [ "$TOTAL_STORAGE" -gt 200 ]; then
    echo "❌ Total boot storage (${TOTAL_STORAGE}GB) exceeds free tier limit (200GB)"
    rm -f tfplan.json
    exit 1
fi
echo "✅ Total storage: ${TOTAL_STORAGE}GB / 200GB (within free tier)"

# Summary
echo ""
echo "=== ✅ All resources within OCI Always Free limits ==="
echo ""
echo "Summary:"
echo "  • Node Shape: VM.Standard.A1.Flex (ARM64)"
echo "  • OCPUs: $TOTAL_OCPUS / 4"
echo "  • Memory: ${TOTAL_MEMORY}GB / 24GB"
echo "  • Storage: ${TOTAL_STORAGE}GB / 200GB"

rm -f tfplan.json
