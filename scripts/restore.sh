#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <backup-file>" >&2
  exit 2
fi
BACKUP="$1"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
tar -xzf "$BACKUP" -C "$ROOT_DIR"
echo "Restored backup $BACKUP"
