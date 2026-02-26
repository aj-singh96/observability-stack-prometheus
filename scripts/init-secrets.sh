#!/bin/bash
set -euo pipefail

# Initialize secrets in AWS Secrets Manager. Requires AWS CLI configured.
SECRETS=("grafana_admin_password" "prometheus_basic_auth" "alertmanager_basic_auth" "smtp_credentials")

for s in "${SECRETS[@]}"; do
  if aws secretsmanager describe-secret --secret-id "$s" >/dev/null 2>&1; then
    echo "Secret $s exists, skipping"
  else
    aws secretsmanager create-secret --name "$s" --secret-string "REPLACE_ME_${s}"
    echo "Created secret $s. Please update value via AWS console or aws secretsmanager put-secret-value."
  fi
done

echo "Ensure that instance profile has SecretsManagerReadWrite policy attached."
