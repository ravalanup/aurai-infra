SHELL := /usr/bin/env bash
CHART := charts/aurai-platform
ENV ?= dev

.PHONY: help lint template up down status port-forward tf-fmt tf-init tf-validate tf-plan

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

lint: ## Lint the Helm chart for every environment
	helm lint $(CHART) -f $(CHART)/values-local.yaml
	helm lint $(CHART) -f $(CHART)/values-aws.yaml -f $(CHART)/values-dev.yaml
	helm lint $(CHART) -f $(CHART)/values-aws.yaml -f $(CHART)/values-staging.yaml
	helm lint $(CHART) -f $(CHART)/values-aws.yaml -f $(CHART)/values-prod.yaml

template: ## Render the chart locally (set ENV=local|dev|staging|prod)
	@if [ "$(ENV)" = "local" ]; then \
	  helm template aurai-platform $(CHART) -f $(CHART)/values-local.yaml; \
	else \
	  helm template aurai-platform $(CHART) -f $(CHART)/values-aws.yaml -f $(CHART)/values-$(ENV).yaml; \
	fi

up: ## Create the kind cluster and install the platform
	./local/scripts/up.sh

down: ## Delete the kind cluster
	./local/scripts/down.sh

status: ## Show platform pods, services and volumes
	kubectl get pods,svc,pvc -n aurai-system

port-forward: ## Forward platform services to localhost
	./local/scripts/port-forward.sh

tf-fmt: ## Format all Terraform
	terraform -chdir=terraform fmt -recursive

tf-init: ## terraform init without a backend (ENV=dev|staging|prod)
	terraform -chdir=terraform/environments/$(ENV) init -backend=false

tf-validate: tf-init ## Validate one environment
	terraform -chdir=terraform/environments/$(ENV) validate

tf-plan: ## Plan one environment (needs AWS credentials and the state bucket)
	terraform -chdir=terraform/environments/$(ENV) init
	terraform -chdir=terraform/environments/$(ENV) plan