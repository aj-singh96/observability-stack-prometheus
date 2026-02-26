# Runbooks

This document contains 15 operational runbooks: 10 for SLO incidents and 5 for cost anomalies.

## SLO Runbooks

### 1. Fast Burn-Rate Alert (14.4x over 5m + 30m windows)

**Severity:** Critical  
**Condition:** Error budget burning at 14.4x or higher over both 5m and 30m windows  
**Impact:** ~1 hour to error budget exhaustion

**Steps:**
1. Page on-call immediately
2. Check `docker-compose ps` on affected instance
3. Identify failed service: `docker-compose logs -f <service>` (e.g., app, prometheus)
4. Common causes:
   - Database unavailable → check `docker ps; docker logs <db>`
   - Deployment issue → revert last change: `git log --oneline -5; git revert <commit>`
   - Resource exhaustion → check `free -h; df -h; top`
5. If revert fixes burn rate, investigate root cause post-incident
6. If issue persists >5 min, escalate to platform team

**Diagnostic commands:**
```bash
# Check instance resources
free -h && df -h && top -bn1 | head -20

# Check recent logs
docker-compose logs --tail=100 app
docker-compose logs --tail=100 prometheus

# Check Prometheus metrics for errors
curl -s http://localhost:9090/api/v1/query?query=rate\(http_requests_total\{status=\"5..\"\}\[5m\]\) | jq
```

### 2. Slow Burn-Rate Alert (6x over 1h + 6h windows)

**Severity:** Warning  
**Condition:** Error budget burning at 6x or higher over both 1h and 6h windows  
**Impact:** ~1 week to error budget exhaustion

**Steps:**
1. Schedule incident review (within 24 hours)
2. Gather metrics:
   - Query Grafana SLO Overview dashboard
   - Export Prometheus time-series for last 6 hours: `range(slo:availability)[6h]`
   - Check CloudWatch metrics for infrastructure (CPU, memory, disk)
3. Identify trend:
   - Steady degradation → configuration or capacity issue
   - Gradual increase → typical load growth; consider scaling
   - Spike pattern → external load or cascading errors
4. Implement mitigation:
   - If capacity: add instance or scale-out
   - If config: apply hotfix or rollback
   - If external: rate-limit or circuit-break
5. Post-incident: RCA and preventive measures

**Diagnostic commands:**
```bash
# Gather availability over 6h
curl -s http://localhost:9090/api/v1/query_range?query=slo:availability:1h&start=<6h-ago>&step=10m | jq

# Check service-level breakdown
curl -s http://localhost:9090/api/v1/query?query=slo:multi_service:availability | jq
```

### 3. Latency Breach (p95 > 500ms for 5 min)

**Severity:** Warning  
**Condition:** p95 latency exceeds 500ms for 5+ minutes  
**Impact:** User experience degradation

**Steps:**
1. Check Grafana "SLO Overview" dashboard for latency panel
2. Collect request samples:
   ```bash
   curl -s http://localhost:9090/api/v1/query?query=histogram_quantile\(0.95,rate\(http_request_duration_seconds_bucket\[5m\]\)\) | jq
   ```
3. Identify slow endpoints:
   ```bash
   curl -s 'http://localhost:9090/api/v1/query?query=rate(http_request_duration_seconds_bucket{le="1"}[5m]) by (path)' | jq
   ```
4. Common causes & mitigations:
   - Slow database query → optimize indices or query; enable caching
   - Resource saturation → scale instance or reduce load
   - External API latency → add timeout and retry logic
5. If issue persists, check cloud provider status for regional outages

### 4. Error Rate Breach (> 0.1% for 5 min)

**Severity:** Warning  
**Condition:** Error rate > 0.1% for 5+ minutes  
**Impact:** ~0.1% of requests failing

**Steps:**
1. Check error breakdown by HTTP status code:
   ```bash
   curl -s 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total[5m])) by (status)' | jq
   ```
2. Identify error source:
   - 5xx errors → service degradation; check logs
   - 4xx errors → client-side issue or validation change
   - Connection errors → downstream service unavailable
3. Mitigations by error type:
   - Service error → emergency fix or rollback
   - External service → retry logic, fallback, circuit-break
   - Client issue → broadcast notice to users
4. Root cause analysis post-incident

**Diagnostic commands:**
```bash
# Top error paths
curl -s 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total{status=~"5.."}[5m])) by (path)' | jq

# Error rate by service
curl -s 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total{status=~"5.."}[5m])) by (service)' | jq
```

### 5. Error Budget Exhausted (30-day, remaining = 0)

**Severity:** Critical  
**Condition:** 30-day error budget fully consumed  
**Impact:** SLO is now officially "broken"

**Steps:**
1. SLO is already failed; focus shifts to stability & prevention
2. Pause deployments of non-critical features
3. Convene incident review with engineering & product
4. Discuss error budget recovery strategy:
   - If incident was one-time: plan prevention (post-mortems, testing)
   - If trend is increasing: upgrade capacity or architecture
5. Communicate to stakeholders:
   - Engineering: SLO broken; focus on stability
   - Product: set expectations; no feature deploym ents for X days
   - Operations: monitor vigilantly; prepare rollback plans
6. Plan error budget recovery:
   - Aim to stay > 99.9% for next 30 days
   - Review and fix incidents from this month
   - Implement preventive measures

### 6. SSL Certificate Expiring Soon (< 30 days)

**Severity:** Warning  
**Condition:** SSL certificate expires in < 30 days and > 0 days  
**Impact:** Service will be unreachable when certificate expires

**Steps:**
1. Regenerate self-signed certificate (2048-bit RSA, 365 days):
   ```bash
   ./nginx/generate-ssl.sh
   docker-compose restart nginx
   ```
2. Verify new certificate:
   ```bash
   openssl x509 -in nginx/certs/fullchain.pem -noout -dates
   ```
3. For production, obtain a CA-issued certificate:
   - Request from AWS ACM or Let's Encrypt
   - Mount certificate into nginx container
   - Test in staging before production deployment
4. Set a calendar reminder to renew 60 days before expiry

### 7. Prometheus Config Reload Failed

**Severity:** Critical  
**Condition:** `prometheus_config_last_reload_successful == 0`  
**Impact:** Prometheus will not pick up new scrape targets or rules

**Steps:**
1. Check Prometheus logs:
   ```bash
   docker-compose logs prometheus | tail -50
   ```
2. Common errors & fixes:
   - YAML syntax error in `prometheus.yml` → validate with `yamllint prometheus/prometheus.yml`
   - Invalid metric name in rule → fix regex in `prometheus/alertrules.yml`
   - Missing file reference → check file paths exist
3. Fix and reload:
   ```bash
   docker-compose exec prometheus curl -X POST http://localhost:9090/-/reload
   ```
4. Verify reload success:
   ```bash
   curl -s http://localhost:9090/api/v1/query?query=prometheus_config_last_reload_successful | jq
   ```

### 8. Prometheus Restarts (> 5 restarts/hour)

**Severity:** Warning  
**Condition:** `increase(prometheus_tsdb_reloads_total[1h]) > 5`  
**Impact:** Data loss, query gaps

**Steps:**
1. Check restart logs:
   ```bash
   docker-compose logs --tail=200 prometheus | grep -i "restart\|reload"
   ```
2. Common causes:
   - OOM (Out of Memory) → increase Docker memory limit
   - Disk full → check `df -h` and clean old data
   - Config error → see "Config Reload Failed" runbook
   - Scrape job timeout → increase `scrape_timeout` in `prometheus.yml`
3. Increase memory allocation:
   ```yaml
   # docker-compose.yml
   prometheus:
     mem_limit: 2g  # increase from default
   ```
4. If restarts persist, scale to multi-instance Prometheus with external storage (Thanos, Cortex)

### 9. AlertManager Down

**Severity:** Critical  
**Condition:** `up{job="alertmanager"} == 0` for 2+ minutes  
**Impact:** Alerts are queued but not delivered

**Steps:**
1. Check status:
   ```bash
   docker-compose ps alertmanager
   docker-compose logs alertmanager
   ```
2. Restart:
   ```bash
   docker-compose restart alertmanager
   ```
3. Verify it's healthyexercise:
   ```bash
   curl -s http://localhost:9093/-/healthy | jq
   ```
4. Check configuration:
   ```bash
   docker-compose exec alertmanager alertmanager --version
   cat alertmanager/alertmanager.yml | yamllint -
   ```
5. If config is invalid, fix per "Prometheus Config Reload Failed" runbook

### 10. Instance Down (up == 0 for 2+ min)

**Severity:** Critical  
**Condition:** EC2 instance or exporter unreachable  
**Impact:** Complete service unavailability

**Steps:**
1. Check instance status in AWS Console:
   ```bash
   aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" | jq '.Reservations[].Instances[] | {InstanceId, State}'
   ```
2. If instance is stopped, restart:
   ```bash
   aws ec2 start-instances --instance-ids i-xxxxx
   ```
3. Wait 60 seconds for boot, then verify:
   ```bash
   curl -s http://<instance-ip>/ || echo "Not ready yet"
   ```
4. Check security groups:
   ```bash
   aws ec2 describe-security-groups --group-ids sg-xxxxx | jq '.SecurityGroups[0].IpPermissions'
   ```
5. If networking issue, verify SSH access and Docker containers:
   ```bash
   ssh ec2-user@<instance-ip> 'docker-compose ps'
   ```

---

## Cost Runbooks

### 11. Daily Cost Budget Exceeded ($2/day limit)

**Severity:** Warning  
**Condition:** `increase(aws_cost_total[1d]) > $2.00`  
**Impact:** ~$60/month if sustained

**Steps:**
1. Check cost breakdown by service:
   ```bash
   curl -s 'http://localhost:9091/metrics' | grep aws_cost_by_service | head -5
   ```
2. Identify spike source:
   - EC2 cost increase → check `aws ec2 describe-instances` for unintended instances
   - Data transfer increase → check VPC Flow Logs for traffic anomalies
   - Storage increase → check EBS `aws ec2 describe-volumes` for new volumes
3. If spike is legitimate (e.g., one-time data copy):
   - Acknowledge alert
   - Monitor to ensure it's temporary
   - Plan for next month
4. If spike is unintended:
   - Terminate unintended resources: `aws ec2 terminate-instances --instance-ids i-xxxxx`
   - Remove unused EIPs: `aws ec2 release-address --allocation-id eipalloc-xxxxx`
   - Document root cause

### 12. Monthly Cost Budget Exceeded ($20/month limit)

**Severity:** Warning  
**Condition:** `increase(aws_cost_total[30d]) > $20.00`  
**Impact:** ~$240/year if sustained

**Steps:**
1. Analyze accumulated cost:
   - Was there a large spike or sustained increase?
   - Which service caused the overage?
2. Historical trend:
   ```bash
   # Query last 3 months of cost
   curl -s 'http://localhost:9090/api/v1/query_range?query=increase(aws_cost_total[30d])&start=<90d-ago>&step=1d' | jq
   ```
3. Implement cost optimization (see Cost Guide):
   - Option A: Purchase 1-year Reserved Instance (-$4.52/month, 30% off)
   - Option B: Stop dev instances overnight (-$7.59/month, 50% off)
   - Option C: Remove unnecessary EIP (-$3.65/month)
4. Forecast recovery:
   - With RI: $15.48/month
   - With overnight shutoff: $10.43/month
   - Combined: $4.24/month

### 13. Cost Spike Detected (> 20% from 7-day average)

**Severity:** Warning  
**Condition:** Daily cost > 7-day average × 1.2  
**Impact:** Investigate anomaly; could indicate misconfiguration

**Steps:**
1. Flag dates with spike:
   ```bash
   # In Grafana, use "Cost Overview" dashboard for daily trend
   ```
2. Correlate with operational changes:
   - New EC2 instance launched?
   - VPN or NAT gateway enabled?
   - Large data transfer event?
   - Backup or snapshot operation?
3. If operational (expected), no action needed
4. If unintended:
   - Terminate resources
   - Remove extra configurations
   - Document to prevent recurrence
5. Set up cost forecasting alerts (see Missing Items)

### 14. Cost Forecast Warning (Projected > $25/month)

**Severity:** Info  
**Condition:** 7-day cost × 4.3 > $25 → forecast indicates > $25/month burn  
**Impact:** Exceeds budget; requires attention before month-end

**Steps:**
1. Calculate current burn rate:
   - 7-day cost ÷ 7 = daily cost
   - daily cost × 30 = monthly projection
2. If projection is < $24 (within margin of error), acknowledge and continue monitoring
3. If projection is > $25:
   - Identify cost drivers (use `aws_cost_by_service` metric)
   - Prioritize cost optimization (Reserved Instance, shutdown, right-sizing)
   - If optimization saves < $5/month, accept higher budget for this cycle
   - If optimization saves > $5, implement immediately
4. Re-forecast next week to confirm correction

### 15. Instance Low CPU Utilization (< 5% average for 1h)

**Severity:** Info  
**Condition:** Average CPU < 5% over 1 hour (< 0.05)  
**Impact:** Potential cost inefficiency; instance may be oversized

**Steps:**
1. Confirm low utilization is sustained (not a transient dip):
   ```bash
   # Query last 24h CPU
   curl -s 'http://localhost:9090/api/v1/query_range?query=avg(rate(node_cpu_seconds_total{mode!="idle"}[5m]))&start=<24h-ago>&step=1h' | jq
   ```
2. Check if this is expected (e.g., during off-hours for dev instance):
   - If expected: no action
   - If unexpected: investigate why workload is low
3. Right-sizing options:
   - **t3.small → t3.micro:** -$7.59/month (1GB RAM; suitable for dev/test only)
   - **t3.small → t3.nano:** -$9.29/month (512MB RAM; minimal workloads only)
   - **Consider:** Metrics volume ~2K per t3.micro; if producing >2K, stay on t3.small
4. If downsize is viable:
   ```bash
   # Update Terraform
   # terraform/environments/dev/terraform.tfvars
   instance_type = "t3.micro"  # was "t3.small"
   
   # Plan and apply
   cd terraform/environments/dev && terraform apply
   ```
5. Monitor for 48 hours post-downsize; revert if insufficient capacity

---

## Incident Commander Checklist

When an SLO or cost alert fires:

- [ ] Acknowledge alert in Alertmanager
- [ ] Page on-call (critical) or schedule meeting (warning)
- [ ] Collect metrics snapshot
- [ ] Identify root cause using appropriate runbook
- [ ] Implement mitigation
- [ ] Verify mitigation (check alert clears within 5 minutes)
- [ ] Document in incident ticket
- [ ] Schedule post-incident review for next business day
- [ ] Close incident ticket only after RCA and preventive measures assigned

