# Future Enhancements

This document lists planned enhancements that are out-of-scope for v2.3.0 but recommended for future iterations.

1. ACM / Let’s Encrypt integration: replace self-signed certificates with AWS ACM or automated Let's Encrypt certificates and configure auto-renewal.
2. Kubernetes migration: provide Helm charts and Kustomize overlays to run the stack on EKS with Autoscaling and PodSecurityPolicies.
3. High-availability: add multi-AZ EC2 instances, load balancer (ALB/NLB) and HA-prometheus (Thanos or Cortex) for long-term storage.
4. Secrets as code: manage Secrets Manager secrets via Terraform with secure values from a secret pipeline (SOPS/GPG/KMS integration).
5. GitOps: provide Flux/Argo manifests for application deployment and automated drift detection with policy enforcement.
6. Grafana SSO: add OIDC/SSO integration (Okta/Azure AD) for enterprise authentication and RBAC.
7. Enhanced cost analytics: integrate Cost and Usage Reports (CUR) + AWS Athena queries and dashboards for granular cost insights.
8. CI/CD hardening: add `tflint`, `checkov`, `terratest` and policy-as-code tests (OPA) into pipelines.
9. Backup & restore: snapshot Prometheus and Grafana state to S3 with versioning, lifecycle rules, and verification hooks.
10. Monitoring federation: add remote_write/remote_read to forward metrics to a central observability cluster.
11. Alert escalation: integrate PagerDuty/SMS/Slack escalation policies and on-call routing per severity and service.
12. Auto-scaling and cost optimization automation: policies to shut down non-production instances on schedule and rightsizing recommendations.
13. Telemetry enrichment: add trace context (OpenTelemetry) and logs ingestion (Loki) for unified observability.

If you want any of these implemented next, tell me which one and I'll add a detailed plan and begin work.
