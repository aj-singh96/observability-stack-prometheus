#!/bin/sh
set -e

AWS_REGION=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/region || echo "us-east-1")
OUT_FILE=.env

echo "# DO NOT COMMIT THIS FILE" > "$OUT_FILE"

# Grafana credentials
GRAFANA_JSON=$(aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id grafana/credentials --query SecretString --output text 2>/dev/null || true)
GRAFANA_USER=$(printf '%s' "$GRAFANA_JSON" | jq -r '.username // .user // .Username // empty')
GRAFANA_PASS=$(printf '%s' "$GRAFANA_JSON" | jq -r '.password // .pass // .Password // empty')

# Alertmanager SMTP
SMTP_JSON=$(aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id alertmanager/smtp --query SecretString --output text 2>/dev/null || true)
SMTP_HOST=$(printf '%s' "$SMTP_JSON" | jq -r '.host // empty')
SMTP_FROM=$(printf '%s' "$SMTP_JSON" | jq -r '.from // empty')
SMTP_USER=$(printf '%s' "$SMTP_JSON" | jq -r '.username // .user // empty')
SMTP_PASS=$(printf '%s' "$SMTP_JSON" | jq -r '.password // .pass // empty')

echo "GRAFANA_USER=${GRAFANA_USER:-admin}" >> "$OUT_FILE"
echo "GRAFANA_PASSWORD=${GRAFANA_PASS:-admin}" >> "$OUT_FILE"
echo "ALERT_SMTP_HOST=${SMTP_HOST:-}" >> "$OUT_FILE"
echo "ALERT_SMTP_FROM=${SMTP_FROM:-}" >> "$OUT_FILE"
echo "ALERT_SMTP_USER=${SMTP_USER:-}" >> "$OUT_FILE"
echo "ALERT_SMTP_PASS=${SMTP_PASS:-}" >> "$OUT_FILE"
