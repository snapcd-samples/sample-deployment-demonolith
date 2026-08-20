#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Creates the two local input files from their committed .sample
# counterparts, if they don't exist yet. Edit them to change inputs;
# steps 2 and 4 load .env themselves.
[ -f .env ] || cp .env.sample .env
[ -f terraform.tfvars ] || cp terraform.tfvars.sample terraform.tfvars

echo "-----------"
echo "Session files ready: .env and terraform.tfvars"
