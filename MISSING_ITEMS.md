# Missing Items Checklist

This file tracks missing items from the Generation Reference.

1. [x] Add `Makefile` with common automation targets
2. [x] Add `FUTURE_ENHANCEMENTS.md`
3. [x] Add Terraform-managed Secrets Manager resources for grafana, prometheus, alertmanager, smtp
4. [x] Wire `terraform/environments/dev` backend to S3 + DynamoDB (enable remote state)
5. [x] Replace placeholder secrets flow so no plaintext placeholders remain
6. [x] Implement `htpasswd` management and secure basic-auth provisioning script
7. [x] Expand Prometheus recording rules to 28 rules (multi-window, availability, latency, error budget)
8. [x] Expand Alerting rules to 25+ alerts (traditional, SLO multi-burn-rate, cost alerts)
9. [x] Populate Grafana dashboards with real panel queries for SLO and Cost
10. [x] Harden `scripts/cost-exporter.py` (date ranges, pagination, retries, metrics labels)
11. [x] Expand `docs/SLO.md` to detailed 600+ line SLO guide
12. [x] Expand `docs/COST.md` to detailed 900+ line cost guide
13. [x] Add 15 runbooks in `docs/RUNBOOKS.md` (10 SLO + 5 cost) ✅ COMPLETED
14. [x] Ensure Terraform modules are fully parameterized and reusable (additional variables/outputs) ✅ COMPLETED
15. [x] Add detailed Grafana provisioning (dashboards as JSON with queries) ✅ COMPLETED
16. [x] Add CI: `terraform fmt`, `tflint`, `terraform validate` across branches ✅ COMPLETED
17. [x] Add production-ready scripts for backup/restore with verification ✅ COMPLETED (verify-backup.sh)
18. [ ] Implement GitOps manifests (Flux/Argo) and approval gates in GitHub Actions (deferred to FUTURE_ENHANCEMENTS)
19. [ ] Final review, formatting, and tag release verification

