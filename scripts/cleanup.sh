#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
docker compose down --volumes || true
rm -rf "$ROOT_DIR/nginx/certs" || true
echo "Cleanup complete"
