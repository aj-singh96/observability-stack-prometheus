#!/bin/bash
set -euo pipefail

# Install Docker + Docker Compose and start the application stack
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
python3 -m pip install --upgrade pip
pip3 install docker-compose
cd /home/ubuntu/app || true
if [[ -f docker-compose.yml ]]; then
  docker compose up -d --build
fi
