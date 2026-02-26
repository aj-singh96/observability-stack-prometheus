# Runbooks

This file contains operational runbooks for common tasks.

1. Restart stack
   - SSH to instance
   - `sudo docker compose restart`

2. Rotate Grafana admin password
   - Update secret `grafana_admin_password` in Secrets Manager
   - Restart Grafana container

3. Investigate alert
   - Check `docker compose logs alertmanager` and Prometheus logs

4. Recover from backup
   - `./scripts/restore.sh <backup-file>`
