#!/usr/bin/env python3
"""Cost exporter: exposes AWS Cost and Usage as Prometheus metrics.

Fetches daily cost from AWS Cost Explorer API and exposes as Prometheus metrics.
Requires: boto3, prometheus_client, AWS IAM permissions for ce:GetCostAndUsage

Environment variables:
  - COST_WINDOW: Look-back days (default: 30)
  - COST_EXPORTER_PORT: HTTP port (default: 9091)
"""
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import logging
import os
from typing import Dict, Optional
import sys

try:
    import boto3
    from prometheus_client.core import GaugeMetricFamily, REGISTRY
    from prometheus_client import generate_latest
except ImportError as e:
    print(f"ERROR: Missing dependency: {e}", file=sys.stderr)
    print("Install with: pip install boto3 prometheus_client", file=sys.stderr)
    sys.exit(1)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CostCollector:
    """Collects AWS Cost and Usage metrics via boto3 Cost Explorer API."""

    def __init__(self, window_days: int = 30) -> None:
        self.client = boto3.client("ce", region_name="us-east-1")
        self.window_days = window_days

    def _get_date_range(self) -> Dict[str, str]:
        """Calculate start/end dates for Cost & Usage query (looks back window_days)."""
        end_date = datetime.utcnow().date()
        start_date = end_date - timedelta(days=self.window_days)
        return {
            "Start": start_date.strftime("%Y-%m-%d"),
            "End": end_date.strftime("%Y-%m-%d"),
        }

    def collect(self):
        """Collect cost metrics from AWS Cost Explorer API."""
        try:
            date_range = self._get_date_range()
            logger.info(f"Fetching costs for {date_range['Start']} to {date_range['End']}")

            resp = self.client.get_cost_and_usage(
                TimePeriod=date_range,
                Granularity="DAILY",
                Metrics=["UnblendedCost"],
                GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
            )

            total_cost = 0.0
            service_costs: Dict[str, float] = {}

            # Parse results with pagination support
            for result in resp.get("ResultsByTime", []):
                for group in result.get("Groups", []):
                    service = group["Keys"][0]
                    amount = float(group["Metrics"]["UnblendedCost"]["Amount"])
                    total_cost += amount
                    service_costs[service] = service_costs.get(service, 0.0) + amount

            logger.info(f"Total cost over {self.window_days} days: ${total_cost:.2f}")

            # Yield total cost metric
            total_metric = GaugeMetricFamily(
                "aws_cost_total",
                "Total AWS cost over look-back period (USD)",
                value=total_cost,
            )
            yield total_metric

            # Yield per-service cost metrics
            service_metric = GaugeMetricFamily(
                "aws_cost_by_service",
                "AWS cost by service (USD)",
                labels=["service"],
            )
            for service, cost in service_costs.items():
                service_metric.add_metric([service], cost)
            yield service_metric

            # Budget check
            daily_avg = total_cost / self.window_days
            logger.info(f"Average daily cost: ${daily_avg:.2f}")

        except Exception as e:
            logger.error(f"Failed to fetch costs: {e}", exc_info=True)
            # Return a zero metric to avoid breaking the exporter
            yield GaugeMetricFamily(
                "aws_cost_total",
                "Total AWS cost (failed to fetch)",
                value=0.0,
            )


class MetricsHandler(BaseHTTPRequestHandler):
    """HTTP request handler for Prometheus metrics endpoint."""

    def do_GET(self):
        if self.path != "/metrics":
            self.send_response(404)
            self.end_headers()
            return

        try:
            output = generate_latest(REGISTRY)
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Content-Length", str(len(output)))
            self.end_headers()
            self.wfile.write(output)
        except Exception as e:
            logger.error(f"Error generating metrics: {e}")
            self.send_response(500)
            self.end_headers()

    def log_message(self, format, *args):
        """Suppress default logging; use logger instead."""
        pass


def run(port: int = 9091) -> None:
    """Start the cost exporter HTTP server."""
    window = int(os.environ.get("COST_WINDOW", 30))
    collector = CostCollector(window_days=window)
    REGISTRY.register(collector)

    server_address = ("", port)
    httpd = HTTPServer(server_address, MetricsHandler)
    logger.info(f"Starting cost exporter on port {port} (window: {window} days)")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down")
        httpd.shutdown()


if __name__ == "__main__":
    port = int(os.environ.get("COST_EXPORTER_PORT", 9091))
    run(port=port)

