#!/bin/bash
set -euo pipefail

# Backup volumes to tar.gz
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${ROOT_DIR}/backups/backup-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
mkdir -p "${ROOT_DIR}/backups"
tar -czf "$OUT" -C "$ROOT_DIR" prometheus grafana || true
echo "Backup stored at $OUT"
