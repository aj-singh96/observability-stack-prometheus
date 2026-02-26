# Cost Guide

This guide explains the cost model, budget alerts and optimization strategies.

Monthly estimate:
- EC2 t3.small: $15.18
- EBS gp3 10GB: $0.80
- EIP (optional): $3.65
- Secrets Manager: $1.60
- Other: $0.50

Budgeting:
- Daily budget: $2/day
- Monthly budget: $20/month

Optimization suggestions:
- Stop dev instances overnight
- Use Reserved Instances or Savings Plans
- Remove unused EIPs

Cost exporter:
- Exposes `aws_cost_total` metric; see `scripts/cost-exporter.py`.
