#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# --engine is explicit because migrate runs real plans; there is no default.
# database_port only ever existed as a -var flag and state does not record
# inputs, so it has to be passed again here.
source .env
demonolith migrate -y --force --engine tofu --var "database_port=5432" 
