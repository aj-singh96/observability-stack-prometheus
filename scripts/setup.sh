#!/bin/bash
set -euo pipefail

# Installs Docker and starts the docker-compose stack
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

command -v docker >/dev/null 2>&1 || {
  echo "Docker not found. Installing..."
  curl -fsSL https://get.docker.com | sh
}

command -v docker-compose >/dev/null 2>&1 || {
  echo "docker-compose not found. Installing..."
  apt-get update && apt-get install -y python3-pip
  pip3 install docker-compose
}

cd "$ROOT_DIR"
./nginx/generate-ssl.sh

docker compose up -d --build

echo "Stack started. Run ./scripts/health-check.sh to verify."
