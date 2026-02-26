# Missing Items Checklist

This file tracks missing items from the Generation Reference. We'll complete these one-by-one; the first item is done.

1. [x] Add `Makefile` with common automation targets (done)
2. [x] Add `FUTURE_ENHANCEMENTS.md`
3. [x] Add Terraform-managed Secrets Manager resources for grafana, prometheus, alertmanager, smtp
4. [x] Wire `terraform/environments/dev` backend to S3 + DynamoDB (enable remote state)
5. [x] Replace placeholder secrets flow so no plaintext placeholders remain
6. [ ] Replace placeholder secrets flow so no plaintext placeholders remain
6. [x] Implement `htpasswd` management and secure basic-auth provisioning script
7. [x] Expand Prometheus recording rules to 28 rules (multi-window, availability, latency, error budget)
8. [x] Expand Alerting rules to 25+ alerts (traditional, SLO multi-burn-rate, cost alerts)
10. [ ] Populate Grafana dashboards with real panel queries for SLO and Cost
11. [ ] Harden `scripts/cost-exporter.py` (date ranges, pagination, retries, metrics labels)
12. [ ] Expand `docs/SLO.md` to detailed 600+ line SLO guide
13. [ ] Expand `docs/COST.md` to detailed 900+ line cost guide
14. [ ] Add 15 runbooks in `docs/RUNBOOKS.md` (10 SLO + 5 cost)
15. [ ] Implement GitOps manifests (Flux/Argo) and approval gates in GitHub Actions
16. [ ] Ensure Terraform modules are fully parameterized and reusable (additional variables/outputs)
17. [ ] Add detailed Grafana provisioning (dashboards as JSON with queries)
18. [ ] Add CI: `terraform fmt`, `tflint`, `terraform validate` across branches
19. [ ] Add production-ready scripts for backup/restore with verification
20. [ ] Final review, formatting, and tag release verification
