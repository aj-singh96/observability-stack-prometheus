#!/bin/bash
set -euo pipefail

# Initialize secrets in AWS Secrets Manager. Requires AWS CLI configured.
SECRETS=("grafana_admin_password" "prometheus_basic_auth" "alertmanager_basic_auth" "smtp_credentials")

for s in "${SECRETS[@]}"; do
  if aws secretsmanager describe-secret --secret-id "$s" >/dev/null 2>&1; then
    echo "Secret $s exists, skipping"
  else
    # generate a secure random string (32 bytes base64)
    rand=$(openssl rand -base64 32)
    aws secretsmanager create-secret --name "$s" --secret-string "$rand"
    echo "Created secret $s with a generated value. To override, run aws secretsmanager put-secret-value."
  fi
done

echo "Ensure that instance profile has SecretsManagerReadWrite policy attached."
