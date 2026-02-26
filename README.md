# Enterprise-Grade Prometheus Observability Stack on AWS

Version: v2.3.0

This repository implements a production-ready Prometheus-based observability stack deployable on AWS using Terraform and Docker Compose. It includes security hardening, GitOps workflows, SLO monitoring, cost monitoring, and comprehensive documentation.

See IMPLEMENTATION_PLAN.md for the phased plan and success criteria.

Quick start:

1. Initialize backend: `cd terraform/backend && terraform init && terraform apply`
2. Provision infra (dev): `cd terraform/environments/dev && terraform init && terraform apply`
3. Initialize secrets: `./scripts/init-secrets.sh`
4. Deploy application: SSH to instance and run `./scripts/setup.sh`

Access:
- Grafana: https://<instance-ip>/
- Prometheus: https://<instance-ip>/prometheus (basic auth)
- Alertmanager: https://<instance-ip>/alertmanager (basic auth)
# observability-stack-prometheus
