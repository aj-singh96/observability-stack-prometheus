---

## Context

This is an Enterprise-Grade Prometheus Observability Stack on AWS (v2.3.0). The stack uses Docker Compose to run Prometheus, Grafana, AlertManager, Node Exporter, nginx (reverse proxy with SSL & basic auth), and a custom Python AWS Cost Exporter. Infrastructure is managed with Terraform (modules: ec2, iam, security-group, secrets). The repo includes SLO-based monitoring with multi-window burn-rate alerting per Google SRE Workbook.

**Rules:**
- Run `terraform fmt -recursive terraform/` after all terraform changes
- Keep `terraform/modules/secrets/`, `MISSING_ITEMS.md`, and `GENERATION_PROMPT.md` as-is
- Do NOT create `LINKEDIN_POSTS.md`
- All shell scripts must have execute permissions
- Use `latest` image tags for all Docker images in docker-compose
- Services should expose ports internally only — nginx maps them externally

---

## PART A: Create New Files (17 files)

### A1. `Dockerfile.cost-exporter` (root)
Python 3.11-slim based Dockerfile that installs boto3, copies `scripts/cost-exporter.py` to `/app/`, exposes port 9091, includes a HEALTHCHECK hitting `http://localhost:9091/health`, and runs `python3 /app/cost-exporter.py`.

### A2. `nginx/Dockerfile`
nginx:alpine based Dockerfile that installs openssl, apache2-utils, curl, jq, and awscli (via pip3). Copies `nginx.conf` to `/etc/nginx/conf.d/default.conf` and `entrypoint.sh` to `/entrypoint.sh`. Exposes ports 80, 443, 9090, 9093. Uses `/entrypoint.sh` as ENTRYPOINT.

### A3. `nginx/entrypoint.sh`
Shell script that: (1) creates `/etc/nginx/ssl/` dir, (2) generates a self-signed SSL cert if none exists (RSA 2048, 365 days, CN=prometheus.local), (3) retrieves AWS region from instance metadata (fallback us-east-1), (4) pulls Prometheus and AlertManager credentials from AWS Secrets Manager (`prometheus/prometheus-auth` and `prometheus/alertmanager-auth`), (5) creates htpasswd files at `/etc/nginx/.htpasswd-prometheus` and `/etc/nginx/.htpasswd-alertmanager`, (6) falls back to default passwords if secrets unavailable, (7) starts nginx with `exec nginx -g 'daemon off;'`.

### A4. `scripts/get-secret.sh`
Bash script accepting `<secret-name>` and `<json-key>` as arguments. Gets AWS region from instance metadata, calls `aws secretsmanager get-secret-value`, extracts the specific JSON key using jq, and prints the value. Exits with appropriate error codes on failure.

### A5. `scripts/load-secrets.sh`
Bash script that retrieves secrets from AWS Secrets Manager and generates a `.env` file containing: `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` (from `prometheus/grafana`), SMTP settings (from `prometheus/alertmanager`), and `AWS_REGION`. Warns user to add `.env` to `.gitignore`.

### A6. `prometheus/cost-alerts.yml`
Prometheus alerting rules for AWS cost monitoring. Two groups:
- **cost_alerts** (interval: 5m): `HighDailyCost` (>$2/day), `MonthlyBudgetExceededDev` (>$20/mo dev), `MonthlyBudgetExceededProd` (>$50/mo prod), `CostSpike` (>20% vs 7-day avg), `MonthlyBudgetWarningDev` (80% of $20), `MonthlyBudgetWarningProd` (80% of $50), `CostExporterDown` (10m), `CostDataStale` (>2h since update)
- **cost_optimization** (interval: 1h): `HighServiceCost` (any service >$10/month over 24h)

### A7. `prometheus/slo-alerts.yml`
SLO-based alerting rules using multi-window multi-burn-rate approach (Google SRE Workbook). Groups:
- **slo_fast_burn** (30s): `SLOFastBurnRate` – burn_rate:1h AND burn_rate:5m both > 14.4 – critical (budget exhaustion in ~2h)
- **slo_slow_burn** (1m): `SLOSlowBurnRate` – burn_rate:6h AND burn_rate:30m both > 6 – warning (budget exhaustion in ~5d)
- **slo_error_budget** (5m): `ErrorBudgetNearlyExhausted` (<10% remaining) and `ErrorBudgetExhausted` (<=0)
- **slo_latency** (1m): `HighLatencyP95` (>500ms) and `CriticalLatencyP99` (>1s)
- **slo_errors** (1m): `HighErrorRate` (>0.1%) and `CriticalErrorRate` (>5%)
- **ssl_certificate_expiry** (1h): `SSLCertificateExpiringSoon` (<30 days) and `SSLCertificateExpiringImminent` (<7 days)
- **slo_multi_service** (30s): `MultipleServicesDown` (>=2 of grafana/prometheus/alertmanager down)

All alerts reference recording rules from slo-rules.yml (e.g., `slo:burn_rate:1h`, `sli:grafana:latency:p95`, `sli:grafana:errors:rate5m`, `slo:error_budget:remaining:ratio`).

### A8. `prometheus/slo-rules.yml`
SLO recording rules that pre-calculate SLIs. Groups:
- **sli_availability** (30s): `sli:{service}:availability:rate5m` for grafana (HTTP 2xx rate), prometheus (query API 200 rate), alertmanager (alerts API 200 rate)
- **sli_latency** (30s): `sli:{service}:latency:{p95,p99}` using `histogram_quantile` for grafana and prometheus
- **sli_errors** (30s): `sli:{service}:errors:rate5m` (5xx rate) for grafana, prometheus, alertmanager
- **slo_error_budget** (1m): `slo:error_budget:remaining:ratio` (30d window, 99.9% SLO target) and `slo:error_budget:burn_rate:ratio`
- **slo_burn_rate** (30s): `slo:burn_rate:{1h,5m,6h,30m}` – multi-window burn rates against 99.9% SLO
- **sli_uptime** (1m): `sli:service:up` and `sli:service:availability:{1h,24h,7d,30d}` using `avg_over_time(up[window])`

### A9. `grafana/dashboards/dashboard-provider.yml`
Grafana dashboard provisioning config (apiVersion: 1). Single provider named `Default`, orgId 1, type file, updateIntervalSeconds 10, allowUiUpdates true, path `/etc/grafana/provisioning/dashboards`, foldersFromFilesStructure true.

### A10. `terraform/environments/dev/terraform.tfvars.example`
Example tfvars for dev: aws_region=us-west-2, vpc_id/subnet_ids as placeholders, ami_id placeholder (Ubuntu 22.04 LTS), instance_type=t3.small, key_name placeholder, instance_count=1, volume_size=20, create_eip=false, owner/cost_center placeholders, ssh_cidr_blocks=["0.0.0.0/0"], allowed_cidr_blocks=["0.0.0.0/0"] with comment to restrict in production.

### A11. `terraform/environments/prod/terraform.tfvars.example`
Same as A10 but: instance_type=t3.medium, volume_size=50, create_eip=true, 2 subnets, ssh_cidr_blocks=["10.0.0.0/8"], allowed_cidr_blocks=["10.0.0.0/8"].

### A12. `terraform/backend/outputs.tf`
Terraform outputs: `s3_bucket_name`, `s3_bucket_arn`, `dynamodb_table_name`, `dynamodb_table_arn`, `github_actions_policy_arn`, and a `backend_config` heredoc showing dev/prod backend configuration and GitHub Secrets to configure.

### A13. `terraform/backend/README.md`
Comprehensive README covering: resources created (S3 bucket with versioning+encryption, DynamoDB for locking), quick setup, manual AWS CLI setup, GitHub Secrets config table (TF_STATE_BUCKET, TF_STATE_LOCK_TABLE, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, SSH_PRIVATE_KEY), backend config examples for dev/prod, state migration guide, troubleshooting (lock errors, init failures), estimated cost (~$0.11/month), security best practices, cleanup instructions.

### A14. `.github/workflows/ci.yml`
CI Pipeline on push/PR to main+develop. Jobs: (1) **lint** – markdown lint + YAML lint on docker-compose.yml, prometheus/, grafana/, alertmanager/. (2) **terraform** (needs lint) – setup terraform, `terraform fmt -check -recursive`, validate dev + prod with `init -backend=false`. (3) **docker** (needs lint) – setup buildx, `docker-compose config`. (4) **security** (needs terraform+docker) – Trivy fs scan in table format.

### A15. `.github/workflows/docker-validate.yml`
Docker Validation on push/PR to main+develop, path-filtered to docker-compose.yml and prometheus/grafana/alertmanager. Single job: checkout, setup buildx, validate compose, `docker-compose up -d`, sleep 30, health-check all 4 services (prometheus, grafana, alertmanager, node-exporter), cleanup with `docker-compose down -v` (always).

### A16. `.github/workflows/security-scan.yml`
Security Scan on push/PR to main+develop plus weekly cron (Sunday midnight). Two jobs: (1) **trivy-scan** – Trivy fs mode → SARIF → upload to GitHub Security. (2) **checkov-scan** – Checkov IaC scan on terraform/ → SARIF → upload to GitHub Security.

### A17. `ARCHITECTURE.md` (root)
Architecture documentation with 8 mermaid diagrams: (1) Detailed Architecture showing all services + connections, (2) Simplified Component View, (3) Deployment Flow from git push through terraform to running stack, (4) Terraform Module Structure (ec2/iam/security-group/secrets), (5) Data Flow (metrics collection → prometheus → grafana), (6) Alert Flow (rules → alertmanager → email/slack), (7) Backup & Restore flow using S3, (8) Environment Comparison table (dev vs prod). Include component descriptions, ports, and interconnections.

---

## PART B: Update Existing Files (8 files)

### B1. Replace `docker-compose.yml`
version 3.8, `monitoring` bridge network, 3 named volumes (prometheus_data, grafana_data, alertmanager_data). All services join `monitoring` network with container_name + restart: unless-stopped.
- **nginx**: build ./nginx/Dockerfile, ports 80/443/9090/9093, depends_on prometheus+alertmanager+grafana, env AWS_REGION
- **prometheus**: latest, command with config.file + tsdb.path + 30d retention + console libs/templates + lifecycle, volumes for ALL 5 prometheus configs + targets.json + data, depends_on alertmanager, expose 9090 only
- **alertmanager**: latest, command with config.file + storage.path, volumes for config + data, expose 9093 only
- **grafana**: latest, env admin_user/password (defaults), ALLOW_SIGN_UP=false, ROOT_URL, plugins, volumes for data + `./grafana/datasources` + `./grafana/dashboards`, depends_on prometheus, expose 3000 only
- **node-exporter**: latest, command with procfs/sysfs/rootfs + fs exclude, no volumes for /proc /sys /, ports 9100:9100
- **cost-exporter**: build ./Dockerfile.cost-exporter, env AWS creds + region + port 9091 + interval 3600, ports 9091:9091, healthcheck

### B2. Replace `prometheus/prometheus.yml`
global: scrape_interval 15s, evaluation_interval 15s, external_labels (cluster: prometheus-stack, environment: production).
Alerting → alertmanager:9093, rule_files: all 4 enabled (alert.rules.yml, slo-rules.yml, slo-alerts.yml, cost-alerts.yml).
Scrape configs: prometheus, node-exporter, alertmanager, grafana, cost-exporter (5m interval, 30s timeout), file-sd (targets.json, 30s refresh). Each target with descriptive instance labels.

### B3. Replace `prometheus/alertrules.yml`
Replace massive consolidated file with ONLY basic system + prometheus alerts (SLO/cost alerts are in separate files now). Two groups:
- **system_alerts** (30s): InstanceDown, HighCPUUsage (>80%), HighMemoryUsage (>85%), DiskSpaceLow (<15%), DiskSpaceCritical (<10%), HighDiskIO, NetworkErrors
- **prometheus_alerts** (30s): PrometheusConfigReloadFailed, PrometheusTooManyRestarts (>2/15m), AlertmanagerDown

### B4. Replace `terraform/environments/dev/main.tf`
required_version >= 1.5.0, aws ~> 5.0, S3 backend COMMENTED OUT with instructions. Provider with default tags (Project, Environment=dev, ManagedBy). Modules: security_group (passes name/vpc_id/environment/ssh_cidr_blocks/allowed_cidr_blocks), **secrets** (secret_names: grafana_admin_password, prometheus_basic_auth, alertmanager_basic_auth, smtp_credentials), iam (passes name/environment), ec2 (passes all vars including security_group_ids from module output + iam_instance_profile from module output + cost_center + application).

### B5. Replace `terraform/environments/prod/main.tf`
Same as B4 but key=prometheus/prod/terraform.tfstate, Environment=prod.

### B6. Replace `terraform/environments/dev/variables.tf`
All variables with descriptions and types: aws_region (default us-west-2), project_name (default prometheus-stack-dev), environment (default dev), vpc_id, subnet_ids (list), ami_id, instance_type (default t3.small), key_name, instance_count (default 1), volume_size (default 20), create_eip (default false), owner, cost_center, application (default monitoring), ssh_cidr_blocks (default ["0.0.0.0/0"]), allowed_cidr_blocks (default ["0.0.0.0/0"]).

### B7. Replace `terraform/environments/prod/variables.tf`
Same as B6 but: project_name default prometheus-stack-prod, environment default prod, instance_type default t3.medium, volume_size default 50, create_eip default true, ssh_cidr_blocks NO default (required), allowed_cidr_blocks NO default (required).

### B8. Update `terraform/environments/{dev,prod}/outputs.tf`
Dev outputs: instance_ids, instance_public_ips, instance_public_dns, security_group_id, prometheus_url, grafana_url (using public_ips). Prod outputs: same plus elastic_ips and alertmanager_url, with URL outputs preferring elastic_ip then falling back to public_ip.

---

## PART C: Structural Alignment

### C1. Grafana Datasources Path
Move `grafana/provisioning/datasources/datasources.yaml` to `grafana/datasources/prometheus.yml`. Docker-compose mounts `./grafana/datasources` → `/etc/grafana/provisioning/datasources`. Content: Prometheus datasource, access proxy, url http://prometheus:9090, isDefault true, editable true, jsonData with timeInterval 15s and queryTimeout 60s.

### C2. Remove old provisioning directory
Delete `grafana/provisioning/` directory after moving datasource file.

---

## PART D: Final Steps

1. Run `terraform fmt -recursive terraform/`
2. Verify all shell scripts have execute permissions
3. Run `docker-compose config` to validate
4. Commit: `feat: sync with local repo - add missing files, update configs, align structure`