#!/bin/sh
set -e

AWS_REGION=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/region || echo "us-east-1")
OUT_FILE=.env

echo "# DO NOT COMMIT THIS FILE - Add .env to .gitignore" > "$OUT_FILE"
echo "AWS_REGION=${AWS_REGION}" >> "$OUT_FILE"

# Grafana credentials from prometheus/grafana secret
GRAFANA_JSON=$(aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id prometheus/grafana --query SecretString --output text 2>/dev/null || true)
GF_ADMIN_USER=$(printf '%s' "$GRAFANA_JSON" | jq -r '.admin_user // .username // empty' 2>/dev/null || echo "admin")
GF_ADMIN_PASS=$(printf '%s' "$GRAFANA_JSON" | jq -r '.admin_password // .password // empty' 2>/dev/null || echo "admin")

echo "GF_SECURITY_ADMIN_USER=${GF_ADMIN_USER}" >> "$OUT_FILE"
echo "GF_SECURITY_ADMIN_PASSWORD=${GF_ADMIN_PASS}" >> "$OUT_FILE"

# AlertManager SMTP from prometheus/alertmanager secret
SMTP_JSON=$(aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id prometheus/alertmanager --query SecretString --output text 2>/dev/null || true)
SMTP_HOST=$(printf '%s' "$SMTP_JSON" | jq -r '.smtp_host // .host // empty' 2>/dev/null || true)
SMTP_FROM=$(printf '%s' "$SMTP_JSON" | jq -r '.smtp_from // .from // empty' 2>/dev/null || true)
SMTP_USER=$(printf '%s' "$SMTP_JSON" | jq -r '.smtp_user // .username // empty' 2>/dev/null || true)
SMTP_PASS=$(printf '%s' "$SMTP_JSON" | jq -r '.smtp_pass // .password // empty' 2>/dev/null || true)

echo "SMTP_HOST=${SMTP_HOST}" >> "$OUT_FILE"
echo "SMTP_FROM=${SMTP_FROM}" >> "$OUT_FILE"
echo "SMTP_USER=${SMTP_USER}" >> "$OUT_FILE"
echo "SMTP_PASS=${SMTP_PASS}" >> "$OUT_FILE"

echo "Environment file created at $OUT_FILE. Remember to add .env to .gitignore!"
