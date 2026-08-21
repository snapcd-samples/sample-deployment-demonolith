#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Needs nothing from .env: the validate step is credential-free (only the
# provider registry is contacted); everything else is offline. Reversible with git.
# --overwrite: the committed roots/ from the last run are deleted and rewritten.
demonolith refactor -y --monorepo --overwrite --engine tofu 
