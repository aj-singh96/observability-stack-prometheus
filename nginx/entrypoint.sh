#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl
CERT=/etc/nginx/ssl/selfsigned.crt
KEY=/etc/nginx/ssl/selfsigned.key

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=prometheus.local" -keyout "$KEY" -out "$CERT"
fi

# Get AWS region from instance metadata, fallback
AWS_REGION=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/region || echo "us-east-1")

get_secret(){
  name="$1"; key="$2"
  aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id "$name" --query SecretString --output text 2>/dev/null | jq -r --arg k "$key" '. | fromjson?[$k] // .[$k]'
}

PROM_USER="admin"
AM_USER="admin"
PROM_PASS="prometheus"
AM_PASS="alertmanager"

SECPROM=$(get_secret "prometheus/prometheus-auth" "password" 2>/dev/null || true)
SECPROM_USER=$(get_secret "prometheus/prometheus-auth" "username" 2>/dev/null || true)
SECAM=$(get_secret "prometheus/alertmanager-auth" "password" 2>/dev/null || true)
SECAM_USER=$(get_secret "prometheus/alertmanager-auth" "username" 2>/dev/null || true)

if [ -n "$SECPROM_USER" ]; then PROM_USER="$SECPROM_USER"; fi
if [ -n "$SECPROM" ]; then PROM_PASS="$SECPROM"; fi
if [ -n "$SECAM_USER" ]; then AM_USER="$SECAM_USER"; fi
if [ -n "$SECAM" ]; then AM_PASS="$SECAM"; fi

# Create htpasswd files
echo "$PROM_PASS" | htpasswd -ci "/etc/nginx/.htpasswd-prometheus" "$PROM_USER" <&0
echo "$AM_PASS" | htpasswd -ci "/etc/nginx/.htpasswd-alertmanager" "$AM_USER" <&0

exec nginx -g "daemon off;"
