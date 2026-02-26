#!/bin/bash
set -euo pipefail

# Generate htpasswd file for nginx basic auth on Prometheus and Alertmanager endpoints.
# Usage: ./scripts/gen-htpasswd.sh [output_file]

OUTPUT="${1:-.htpasswd}"
HTPASSWD_FILE="/etc/nginx/${OUTPUT}"

echo "Generating htpasswd file for basic auth..."

if [[ ! -x $(command -v htpasswd) ]]; then
  echo "htpasswd not found. Installing apache2-utils..."
  apt-get update && apt-get install -y apache2-utils || true
fi

# Create or update htpasswd entries
# Entry 1: prometheus user
read -sp "Enter password for 'prometheus' user: " PROM_PASS
echo
htpasswd -bc "$HTPASSWD_FILE" "prometheus" "$PROM_PASS"

# Entry 2: alertmanager user
read -sp "Enter password for 'alertmanager' user: " ALERT_PASS
echo
htpasswd -b "$HTPASSWD_FILE" "alertmanager" "$ALERT_PASS"

chmod 600 "$HTPASSWD_FILE"
echo "Generated $HTPASSWD_FILE (mode 600). Mount this into nginx container."
