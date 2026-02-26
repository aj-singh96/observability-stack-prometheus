#!/usr/bin/env python3
"""Cost exporter: exposes AWS Cost as Prometheus metrics.

Requires: boto3, prometheus_client
"""
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
from typing import Tuple

import boto3
from prometheus_client.core import GaugeMetricFamily, REGISTRY
from prometheus_client import generate_latest


class CostCollector:
    def __init__(self) -> None:
        self.client = boto3.client('ce')

    def collect(self):
        # Query last 30 days cost
        resp = self.client.get_cost_and_usage(
            TimePeriod={
                'Start': (os.environ.get('COST_START', '') or ''),
                'End': (os.environ.get('COST_END', '') or '')
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost']
        )
        total = 0.0
        for r in resp.get('ResultsByTime', []):
            amount = float(r['Total']['UnblendedCost']['Amount'])
            total += amount

        g = GaugeMetricFamily('aws_cost_total', 'Total AWS cost', value=total)
        yield g


class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != '/metrics':
            self.send_response(404)
            self.end_headers()
            return
        output = generate_latest(REGISTRY)
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain; version=0.0.4')
        self.send_header('Content-Length', str(len(output)))
        self.end_headers()
        self.wfile.write(output)


def run(server_class=HTTPServer, handler_class=MetricsHandler, port=9091):
    REGISTRY.register(CostCollector())
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting cost exporter on {port}')
    httpd.serve_forever()


if __name__ == '__main__':
    run()
