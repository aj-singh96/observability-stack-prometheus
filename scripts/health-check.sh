#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Checking services..."
services=(80 443 9090 9093 3000 9100 9091)
for p in "${services[@]}"; do
  if ss -lnt | grep -q ":$p "; then
    echo "Port $p: LISTEN"
  else
    echo "Port $p: NOT LISTENING" >&2
  fi
done

curl -sfk https://localhost/ || echo "Grafana endpoint not healthy"
curl -sfk https://localhost/prometheus/ || echo "Prometheus endpoint not healthy"

echo "Health check complete"
