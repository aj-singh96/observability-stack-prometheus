#!/bin/sh
set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <secret-name> <json-key>" >&2
  exit 2
fi

SECRET_NAME="$1"
JSON_KEY="$2"

AWS_REGION=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/region || echo "us-east-1")

VAL=$(aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text 2>/dev/null | jq -r --arg k "$JSON_KEY" '. | fromjson?[$k] // .[$k]')

if [ -z "$VAL" ] || [ "$VAL" = "null" ]; then
  echo "Secret or key not found" >&2
  exit 3
fi

printf '%s\n' "$VAL"
