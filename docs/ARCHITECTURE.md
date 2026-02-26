# Architecture Diagrams

## Full Architecture

```mermaid
flowchart LR
  Browser --> NGINX[NGINX TLS Termination]
  NGINX --> Grafana
  NGINX --> Prometheus
  NGINX --> Alertmanager
  Prometheus --> NodeExporter
  Prometheus --> CostExporter
  Prometheus --> Alertmanager
  Grafana --> Prometheus
```

## Terraform Modules

```mermaid
graph TD
  Terraform --> Backend
  Terraform --> Modules
  Modules --> EC2
  Modules --> IAM
  Modules --> SecurityGroup
```
