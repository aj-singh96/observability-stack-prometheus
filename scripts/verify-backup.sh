#!/bin/bash
set -euo pipefail

# Verify backup integrity and list contents
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <backup-file>" >&2
  exit 2
fi

BACKUP="$1"
if [[ ! -f "$BACKUP" ]]; then
  echo "Backup file not found: $BACKUP" >&2
  exit 1
fi

echo "Verifying backup: $BACKUP"
tar -tzf "$BACKUP" >/dev/null 2>&1 || {
  echo "ERROR: Backup is corrupted (not valid tar.gz)" >&2
  exit 3
}

echo "✓ Backup is valid"
echo ""
echo "Backup contents:"
tar -tzf "$BACKUP" | head -20
echo "..."
echo ""
echo "To restore: ./scripts/restore.sh $BACKUP"
