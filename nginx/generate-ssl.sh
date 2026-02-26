#!/bin/bash
set -euo pipefail

# Generate self-signed certs (2048-bit RSA, 365 days)
OUT_DIR="$(dirname "$0")/certs"
mkdir -p "$OUT_DIR"

if [[ -f "$OUT_DIR/fullchain.pem" ]]; then
  echo "Certificates already exist in $OUT_DIR"
  exit 0
fi

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$OUT_DIR/privkey.pem" \
  -out "$OUT_DIR/fullchain.pem" \
  -subj "/C=US/ST=State/L=City/O=Org/OU=IT/CN=localhost"

echo "Generated self-signed certificate at $OUT_DIR"
