# Cost Guide

This guide explains the cost model, budgeting strategies, optimization opportunities, and automated cost monitoring for the Prometheus observability stack on AWS.

## Monthly Cost Breakdown

The stack runs on a **t3.small** EC2 instance in the **us-east-1** region with the following monthly costs:

| Component | Cost | Notes |
|-----------|------|-------|
| EC2 t3.small | $15.18 | On-demand hourly rate × 730 hours/month |
| EBS gp3 10GB | $0.80 | $0.08/GB/month |
| Elastic IP (optional) | $3.65 | Not required for dev; $3.65 if used in prod |
| Secrets Manager (4 secrets) | $1.60 | $0.40/secret/month |
| Data transfer out | $0.50 | Variable; typically minimal for monitoring |
| **Total** | **~$20/month** | Within typical org monitoring budget |

### Cost Drivers

1. **EC2 Instance** — Largest component (76% of cost). t3.small provides 2 vCPUs, 2GB RAM (sufficient for ~10K metrics).
2. **Elastic IP** — Only needed for static IPs in prod. Remove in dev to save $3.65.
3. **EBS Storage** — Minimal; 10GB is plenty for 30-day Prometheus retention.
4. **Secrets Manager** — Fixed cost per secret; bundle unrelated secrets to reduce count if budget-constrained.

## Budget Alerts

The stack implements automated budget alerts:

- **Daily Budget:** $2/day (soft limit)
- **Monthly Budget:** $20/month (hard limit)
- **Cost Spike Alert:** >20% deviation from 7-day average → investigate anomalies

When `DailyCostBudgetExceeded` or `MonthlyCostBudgetExceeded` alerts fire, review recent changes:
- New instance types or sizing
- Increased data transfer (NAT gateway, cross-region replication)
- Unintended resource creation (duplicate instances, snapshots)

## Cost Optimization Strategies

### 1. Stop Dev Instances Overnight (Save ~50% or -$9.75/month)
Strategy: Schedule EC2 instance shutdown at 6 PM and restart at 8 AM weekdays (removes 12 hrs × 22 days).
```bash
# Example: Use AWS Lambda + EventBridge to stop instances daily
# Cost impact: -$7.59/month for t3.small
```

### 2. Reserved Instances / Savings Plans (Save ~30% or -$4.52/month)
- **1-year RI:** 32% discount on t3.small → $10.31/month
- **3-year RI:** 54% discount on t3.small → $6.99/month
- **Compute Savings Plan (1-year, 30% discount):** -$4.52/month
- **Trade-off:** Commit resources upfront; less flexibility for downsizing

### 3. Remove Unused Elastic IP (Save $3.65/month)
- Dev environment doesn't need a fixed IP.
- Allocate EIP only in prod if DNS failover requires static IP.

### 4. Downsize to t3.micro (Save ~50% or -$7.59/month)
- **Consideration:** t3.micro has only 1GB RAM; suitable only for light testing.
- **Metrics throughput:** Estimated ~2K metrics (vs. 10K for t3.small).
- **Recommendation:** Keep t3.small for production; use t3.micro for dev/sandbox only.

### 5. Consolidate Secrets Manager Secrets (Save $1.20/month)
- Current: 4 secrets × $0.40 = $1.60
- If budget-constrained, store all secrets in 1 secret as JSON → $0.40/month
- **Trade-off:** Less granular access control; requires JSON parsing in application.

### Combined Optimization Scenario
| Strategy | Monthly Savings |
|----------|-----------------|
| Stop dev overnight (dev only) | -$7.59 |
| 1-year Reserved Instance | -$4.52 |
| Remove EIP (if not needed) | -$3.65 |
| **Total Savings** | **-$15.76 (79% reduction)** |
| **New Monthly Cost** | **~$4.24** |

## Cost Exporter Metrics

The stack exposes cost metrics via `scripts/cost-exporter.py` (port 9091):

- `aws_cost_total` — Cumulative cost over look-back period (default: 30 days, configurable via `COST_WINDOW` env var)
- `aws_cost_by_service{service="..."}` — Per-service cost breakdown

### Configuration
```bash
# Default: 30-day look-back
docker-compose up cost-exporter

# Custom: 7-day look-back
COST_WINDOW=7 docker-compose up cost-exporter
```

### Cost Alerts (in Prometheus)
- **DailyCostBudgetExceeded:** `increase(aws_cost_total[1d]) > 2`
- **MonthlyCostBudgetExceeded:** `increase(aws_cost_total[30d]) > 20`
- **CostSpikeLarge:** >20% change from 7-day average
- **CostForecastWarning:** >$25/month projected burn

## Runbooks

### Cost Alert: Daily Budget Exceeded
1. Check `aws_cost_by_service` to identify spike source.
2. Review EC2 instances: any new instances created? Size change?
3. Check data transfer: any new VPN, NAT, or cross-region copy jobs?
4. If spike is temporary (e.g., one-time data copy), acknowledge and monitor.
5. If spike is sustained, implement one of the optimization strategies above.

### Cost Alert: Monthly Budget Exceeded
1. Review accumulated cost for the month.
2. Identify trend: is daily spend increasing, or was there a large spike?
3. If trend is increasing, prioritize Reserved Instance purchase to lock in savings.
4. If spike occurred, investigate root cause (see daily budget runbook).
5. For next month, implement cost optimization strategy to stay within budget.

### Cost Alert: Forecast Warning
1. Current 7-day burn × 4.3 > $25/month (projected)
2. Identify driver using `aws_cost_by_service` metric.
3. If driven by compute, consider Reserved Instance.
4. If driven by data transfer, evaluate architecture (e.g., consolidate regions).

## Tagging & Cost Allocation

To improve cost attribution, tag all resources:
```hcl
# terraform/modules/ec2/main.tf example
tags = {
  Project     = "Prometheus Observability Stack"
  Environment = var.environment
  Owner       = var.owner
  CostCenter  = "Engineering"
}
```

Then query `aws_cost_by_service` grouped by tag (requires AWS Cost & Usage Reports integration).

## Estimated Annual Cost

| Scenario | Monthly | Annual |
|----------|---------|--------|
| **Baseline** (no optimization) | $20.00 | $240 |
| **With Reserved Instance (1y)** | $15.48 | $185.76 |
| **With all optimizations** | $4.24 | $50.88 |

## Next Steps

1. **Monitor:** Set up cost alerts in Grafana (dashboard: Cost Overview).
2. **Optimize:** Choose optimization strategies based on workload patterns.
3. **Review:** Monthly cost review with stakeholders; adjust budget if needed.
4. **Forecast:** Use AWS Cost Forecast feature for quarterly planning.

## References

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Cost & Usage Reports](https://docs.aws.amazon.com/cur/latest/userguide/)
- [EC2 Instance Types & Pricing](https://aws.amazon.com/ec2/pricing/)
- [Secrets Manager Pricing](https://aws.amazon.com/secrets-manager/pricing/)

