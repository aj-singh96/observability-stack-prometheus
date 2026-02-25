# Generation Reference - Prometheus Observability Stack v2.3.0

**Quick Specs:** Production AWS monitoring | 6 services | $20/month | 10 phases complete

---

## Core Architecture

**Services (Docker Compose):**
1. nginx – SSL/TLS reverse proxy, ports 80/443
2. prometheus – 30d retention, SLO rules, port 9090
3. grafana – 2 dashboards (SLO + Cost), port 3000
4. alertmanager – Multi-severity routing, port 9093
5. node-exporter – System metrics, port 9100
6. cost-exporter – Python AWS Cost API, port 9091

**AWS Infrastructure (Terraform):**
- EC2: t3.small (2 vCPU, 2GB RAM), gp3 10GB encrypted
- Security Groups: 22,80,443,9090,9093,9100,9091
- Secrets Manager: 4 secrets (grafana, prometheus, alertmanager, smtp)
- IAM: Instance profile with Secrets Manager + Cost Explorer permissions
- Backend: S3 bucket + DynamoDB table for state locking

---

## File Structure

```
├── Makefile, docker-compose.yml, README.md, CHANGELOG.md, LICENSE (MIT)
├── IMPLEMENTATION_PLAN.md (10 phases ✅), FUTURE_ENHANCEMENTS.md, LINKEDIN_POSTS.md
├── .github/workflows/ (deploy-infrastructure, deploy-application, terraform-validate)
├── alertmanager/ (alertmanager.yml)
├── grafana/ (datasources/, dashboards/)
├── prometheus/ (prometheus.yml, alertrules.yml, targets.json)
├── nginx/ (nginx.conf, generate-ssl.sh)
├── docs/ (ARCHITECTURE.md, SECURITY.md, RUNBOOKS.md, SLO.md, COST.md)
├── scripts/ (setup, backup, restore, cleanup, health-check, init-secrets, cost-exporter.py)
└── terraform/
    ├── backend/ (S3 + DynamoDB setup)
    ├── environments/dev/ & prod/ (main.tf, variables.tf, outputs.tf)
    └── modules/ec2/, iam/, security-group/ (main, variables, outputs, user-data.sh)
```

---

## Key Features

**Phase 1–4: Security** (Secrets Manager, SSL/TLS, nginx auth, IAM roles)  
**Phase 5–6: GitOps** (GitHub Actions pipelines, S3 backend, drift detection)  
**Phase 7–8: SLO** (28 recording rules, 15+ alerts, multi-window multi-burn-rate, 99.9% target)  
**Phase 9: Cost** (Python exporter, budget alerts $2/day $20/mo, optimization guide)  
**Phase 10: Docs** (6 diagrams, 15 runbooks, 600-line SLO guide, 900-line cost guide)  

---

## Alerts (25+ total)

**Traditional:** InstanceDown, HighCPU/Memory/Disk, IOWait, NetworkErrors, ConfigFailed, Restarts  
**SLO:** Fast burn (14.4x), slow burn (6x), latency breach, error budget exhausted, SSL expiry  
**Cost:** Daily/monthly budget exceeded, spike >20%, forecast alerts, optimization opportunities  

---

## SLO Configuration

**Targets:** 99.9% availability (43min/mo budget), p95 < 500ms, error < 0.1%  
**Recording Rules:** 5m/30m/1h/6h/30d windows for availability, latency, error budget, burn rate  
**Multi-Window Alerts:** Long window (1h/6h) + short window (5m/30m) both must breach  
**Dashboards:** SLO Overview (9 panels), error budget tracking, burn rate trends  

---

## Cost Details

**Monthly Breakdown:**
- EC2 t3.small: $15.18 | EBS gp3 10GB: $0.80 | EIP: $3.65 | Secrets: $1.60 | Other: $0.50  
- **Total: ~$20/month**

**Optimization Opportunities (70% savings):**
- Stop dev overnight: -$9.75/mo (50%)
- Reserved Instance 1yr: -$4.52/mo (30%)
- Remove unused EIP: -$3.65/mo
- Downsize to t3.micro: -$7.59/mo (if underutilized)

---

## Terraform Specs

**Modules:**
- **ec2:** Instances, EBS volumes, EIPs, user-data (Docker 2.24.5, 4GB swap, sysctl tuning)
- **iam:** EC2 role + policies (Secrets Manager, Cost Explorer, CloudWatch)
- **security-group:** Ingress rules for 7 ports + egress all

**Environments:**
- **dev:** t3.small, 10GB, no EIP, 0.0.0.0/0 CIDR
- **prod:** t3.small, 10GB, EIP enabled, restricted CIDR

**Backend:** S3 versioned bucket + DynamoDB lock table, created separately

---

## Prometheus Config

**Scrape Jobs (15s interval):** prometheus, node-exporter, alertmanager, grafana, cost-exporter, file-sd  
**Recording Rules (28 total):** slo_availability, slo_latency, slo_error_budget, slo_burn_rate, slo_multi_service  
**Alert Rules (25+ total):** 10 traditional + 15 SLO + 10 cost alerts  
**Storage:** 30-day retention, persistent volume  

---

## GitHub Actions

**deploy-infrastructure.yml:** Terraform plan on PR → approve → apply on merge (dev auto, prod manual)  
**deploy-application.yml:** SSH deployment with health checks, rollback capability  
**terraform-validate.yml:** fmt check, validate, tflint on PR/push  

---

## Security

**Secrets Manager:** grafana_admin_password, prometheus_basic_auth, alertmanager_basic_auth, smtp_credentials  
**SSL/TLS:** Self-signed cert (2048-bit RSA, 365 days), nginx termination  
**Authentication:** Basic auth htpasswd for Prometheus/AlertManager endpoints  
**IAM:** Instance profile, no hardcoded credentials  

---

## Documentation

**ARCHITECTURE.md:** 6 Mermaid diagrams (full arch, simplified, deployment, terraform modules, data flow, alert flow)  
**SECURITY.md:** Secrets setup, SSL config, basic auth, IAM roles  
**RUNBOOKS.md:** 15 procedures (10 SLO + 5 cost) with bash diagnostics  
**SLO.md:** 600+ lines (error budget model, burn rates, Google SRE references)  
**COST.md:** 900+ lines (service breakdown, optimization strategies)  

---

## Formatting Standards

- **YAML:** 2-space indent, explicit types  
- **Terraform:** 2-space, snake_case, `terraform fmt` applied  
- **Bash:** `#!/bin/bash`, `set -e`, functions for reusability  
- **Python:** PEP 8, type hints, docstrings  
- **Mermaid:** Simplified labels, quoted multi-line text  

---

## Deployment

```bash
# 1. Backend
cd terraform/backend && terraform apply

# 2. Secrets
./scripts/init-secrets.sh

# 3. Infrastructure
cd terraform/environments/dev && terraform apply

# 4. Application
ssh ec2-user@<instance-ip>
./scripts/setup.sh

# 5. Verify
./scripts/health-check.sh
```

**Access:**
- Grafana: https://<ip>/
- Prometheus: https://<ip>/prometheus (auth required)
- AlertManager: https://<ip>/alertmanager (auth required)

---

## Success Criteria

✅ All 10 phases (51 tasks) complete  
✅ 99.9% SLO target defined  
✅ 28 recording + 25+ alert rules  
✅ 15 comprehensive runbooks  
✅ GitOps CI/CD with approval gates  
✅ Zero plaintext secrets  
✅ SSL/TLS on all endpoints  
✅ Real-time cost tracking  
✅ 70% cost optimization identified  

**Status:** PROJECT COMPLETE | **Next:** Deploy → Demo → LinkedIn → Jobs