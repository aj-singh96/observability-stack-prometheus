SHELL := /bin/bash
TF := terraform

.PHONY: help fmt validate backend-init backend-apply dev-init dev-apply start stop health init-secrets backup restore lint

help:
	@echo "Makefile targets:"
	@echo "  fmt            - run terraform fmt across terraform/"
	@echo "  validate       - run terraform validate in dev env"
	@echo "  backend-init   - init terraform backend (terraform/backend)"
	@echo "  backend-apply  - apply terraform backend resources"
	@echo "  dev-init       - terraform init in terraform/environments/dev"
	@echo "  dev-apply      - terraform apply in terraform/environments/dev"
	@echo "  start          - start docker-compose stack"
	@echo "  stop           - stop docker-compose stack"
	@echo "  health         - run scripts/health-check.sh"
	@echo "  init-secrets   - run scripts/init-secrets.sh (requires AWS CLI)"
	@echo "  backup         - run scripts/backup.sh"
	@echo "  restore FILE   - restore backup file"
	@echo "  lint           - basic linting for python (pep8)"

fmt:
	@echo "Running terraform fmt..."
	$(TF) fmt -recursive terraform || true

validate:
	@echo "Validating terraform in dev environment..."
	cd terraform/environments/dev && $(TF) validate || true

backend-init:
	@echo "Init terraform backend..."
	cd terraform/backend && $(TF) init

backend-apply:
	@echo "Apply terraform backend resources (S3 + DynamoDB)."
	cd terraform/backend && $(TF) apply -auto-approve

dev-init:
	@echo "Init dev terraform environment..."
	cd terraform/environments/dev && $(TF) init

dev-apply:
	@echo "Apply dev terraform environment (use with care)."
	cd terraform/environments/dev && $(TF) apply -auto-approve

start:
	@echo "Starting docker-compose stack"
	docker compose up -d --build

stop:
	@echo "Stopping docker-compose stack"
	docker compose down

health:
	@echo "Running health-check.sh"
	./scripts/health-check.sh

init-secrets:
	@echo "Initializing secrets (requires AWS CLI configured)"
	./scripts/init-secrets.sh

backup:
	@echo "Creating backup"
	./scripts/backup.sh

restore:
	@echo "Restoring backup $(file)"
	./scripts/restore.sh $(file)

lint:
	@echo "Running basic python lint"
	python3 -m pip install --user flake8 >/dev/null 2>&1 || true
	flake8 scripts || true
