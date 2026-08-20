#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# For illustration the monolith's inputs are deliberately spread across every channel:
#   terraform.tfvars   name_prefix, public_subnet_cidr, private_subnet_cidr
#   .env  (TF_VAR_*)   resource_group_name, vpc_cidr_block
#   -var flag          database_port — exists nowhere on disk
#   -backend-config    state-store access/secret key, kept out of root.tf

source .env
tofu init -reconfigure \
  -backend-config="access_key=${STATE_STORE_ACCESS_KEY}" \
  -backend-config="secret_key=${STATE_STORE_SECRET_KEY}"
tofu apply -auto-approve -var "database_port=5432"

# The baseline gate: -detailed-exitcode returns 0 clean, 1 error, 2 changes.
set +e
tofu plan -detailed-exitcode -var "database_port=5432"
rc=$?
set -e
echo "-----------"
if [ "$rc" -eq 2 ]; then
  echo "Baseline NOT clean: the plan shows pending changes. Resolve the drift before carving." >&2
  exit 2
elif [ "$rc" -ne 0 ]; then
  exit "$rc"
fi
echo "Baseline established: monolith applied and planning clean."
