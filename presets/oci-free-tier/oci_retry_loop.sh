#!/bin/bash
# OCI Free Tier Capacity Retry Loop
# Usage: ./oci_retry_loop.sh

CWD=$(pwd)
echo "Starting OCI Capacity Retry Loop..."
echo "Region: $(grep region terraform.tfvars | cut -d'"' -f2)"
echo "Press [CTRL+C] to stop."

while true; do
  echo "---------------------------------------------------"
  echo "Attempting apply at $(date)..."
  
  # Run tofu apply, auto-approving to allow non-interactive loops
  tofu apply -var-file="terraform.tfvars" -auto-approve
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Success! Resources provisioned."
    break
  else
    echo "❌ Apply failed (Exit Code: $EXIT_CODE). Likely out of capacity."
    echo "   Retrying in 60 seconds..."
    sleep 60
  fi
done
