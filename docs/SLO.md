# Service Level Objectives (SLO)

This document outlines SLO definitions, recording rules, and alerting burn-rate strategy.

Targets:
- Availability: 99.9% (monthly)
- Latency: p95 &lt; 500ms
- Error rate: &lt; 0.1%

Recording rules (examples):
- slo:availability:5m
- slo:availability:30m
- slo:latency_p95:5m

Burn rates:
- Fast burn: 14.4x over 5m
- Slow burn: 6x over 1h

Multi-window alerts combine short and long windows to reduce flapping.

For full details, use the recording rules in `prometheus/alertrules.yml` and dashboards in Grafana.
