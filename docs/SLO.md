# Service Level Objectives (SLOs)

This comprehensive guide covers SLO definitions, error budget calculations, burn-rate alerting, and multi-window strategies for the Prometheus observability stack.

## Overview

An SLO defines the acceptable level of service quality over a period. This stack targets **99.9% availability** (43.2 min/month error budget), p95 latency < 500ms, and error rate < 0.1%.

## SLO Targets

| Metric | Target | Monthly Budget |
|--------|--------|-----------------|
| Availability | 99.9% | 43.2 minutes down |
| p95 Latency | < 500ms | - |
| Error Rate | < 0.1% | - |

## Error Budget Calculation

Error budget is the allowable downtime/errors within a month while still meeting the SLO.

For 99.9% availability over 30 days:
- Total time: 30 × 24 × 60 = 43,200 minutes
- Error budget: (100 - 99.9) × 43,200 / 100 = **43.2 minutes**

Once exhausted, the SLO is considered "broken" and requires incident review.

## Recording Rules

The Prometheus configuration defines **28 recording rules** across multiple time windows:

### Availability (5 rules)
- `slo:availability:5m` — 5-minute availability percentage
- `slo:availability:30m` — 30-minute availability percentage
- `slo:availability:1h` — 1-hour availability percentage
- `slo:availability:6h` — 6-hour availability percentage
- `slo:availability:30d` — 30-day availability percentage

### Latency (6 rules)
- `slo:latency_p95:5m`, `slo:latency_p95:30m`, `slo:latency_p95:1h`, `slo:latency_p95:6h` — p95 latency over various windows
- `slo:latency_p99:5m`, `slo:latency_p99:30m` — p99 latency

### Error Rate (3 rules)
- `slo:error_rate:5m` — 5-minute error rate (%)
- `slo:error_rate:30m` — 30-minute error rate (%)
- `slo:error_rate:1h` — 1-hour error rate (%)

### Error Budget (2 rules)
- `slo:error_budget:30d` — Total error budget (43.2 minutes)
- `slo:error_budget_remaining:30d` — Remaining error budget

### Burn Rate (4 rules)
- `slo:burn_rate:5m`, `slo:burn_rate:30m`, `slo:burn_rate:1h`, `slo:burn_rate:6h` — Rate of error budget consumption

### Multi-Service (2 rules)
- `slo:multi_service:availability` — Per-service availability
- `slo:multi_service:latency_p95` — Per-service p95 latency

## Multi-Window, Multi-Burn-Rate Alerting

This stack implements Google SRE best practices for burn-rate alerting with both short and long windows to reduce alert fatigue.

### Fast Burn-Rate Alert (14.4x threshold)
- **Short window:** 5 minutes
- **Long window:** 30 minutes
- **Threshold:** 14.4x (error budget exhaustion in ~1 hour)
- **Severity:** Critical
- **Use case:** Immediate action required; service is degrading rapidly

Alert triggers when **both** 5m and 30m burn rates exceed 14.4x. This eliminates isolated spikes while catching sustained degradation.

### Slow Burn-Rate Alert (6x threshold)
- **Short window:** 1 hour
- **Long window:** 6 hours
- **Threshold:** 6x (error budget exhaustion in ~1 week)
- **Severity:** Warning
- **Use case:** Gradual degradation; schedule incident review

Alert triggers when **both** 1h and 6h burn rates exceed 6x, indicating sustained issues over hours.

## Additional SLO Alerts

**Latency Breach:** p95 latency > 500ms for 5 minutes → Warning  
**Error Rate Breach:** Error rate > 0.1% for 5 minutes → Warning  
**Error Budget Exhausted:** Remaining budget ≤ 0 for 1 minute → Critical  
**SSL Expiry:** Certificate expires within 30 days → Warning

## Dashboards

The **SLO Overview** dashboard in Grafana shows:

1. **30-Day Availability (%)** — Gauge of current availability
2. **Error Budget Remaining (minutes)** — Real-time budget consumption
3. **Burn Rate (5m window)** — Rate of budget depletion
4. **p95 Latency (seconds)** — Current latency percentile
5. **Error Rate (%)** — Percentage of failed requests

Refresh interval: 30 seconds.

## Query Examples

### Check error budget status
```promql
slo:error_budget_remaining:30d
```

### Identify high-burn services
```promql
slo:multi_service:availability < 99.9
```

### Calculate impact of an incident
If an incident consumed 10 minutes of error budget:
- Remaining: 43.2 - 10 = 33.2 minutes
- Allowed downtime: ~33.2 more minutes in the month
- Action: If recurrence, prevent escalation or plan maintenance windows

## Runbooks

**On SLO alert:**
1. Check burn-rate alert type (fast vs. slow)
2. For fast burn: page on-call, begin mitigation
3. For slow burn: schedule meeting, analyze trends
4. Post-incident: review error budget consumption, preventive measures

**On error budget exhaustion:**
1. All further errors are "free" (SLO already failed)
2. Focus on stability and prevention
3. Do not deploy risky changes
4. Plan error budget recovery strategies

## References

- [Google SRE: SLOs and Error Budgets](https://sre.google/books/site-reliability-engineering/)
- [Prometheus Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)

