#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Start the simulated S3 state store and create the bucket the backend
# expects. Readiness is polled from outside the container; everything here
# is idempotent, so re-running is always safe.
docker compose up -d --quiet-pull
for i in $(seq 30); do
  curl -sf http://localhost:9000/minio/health/live >/dev/null && break
  [ "$i" -eq 30 ] && { echo "state store did not come up" >&2; docker compose logs minio; exit 1; }
  sleep 2
done
docker run --rm --network host --entrypoint sh minio/mc:latest \
  -c "mc alias set store http://localhost:9000 minioadmin minioadmin >/dev/null && mc mb --ignore-existing store/tfstate"
echo "State store ready: http://localhost:9000 (bucket: tfstate)"
