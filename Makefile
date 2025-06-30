# Makefile for CKAN Docker project

# CKAN version to build
VERSION ?= 2.11

# Directory containing CKAN image build scripts
CKAN_IMAGE_DIR = ckan-docker-base

# Default goal - show help when running 'make' without arguments
.DEFAULT_GOAL := help

.PHONY: build-base build-dev build-all help setup up dev restart stop logs status env swarm-init swarm-build swarm-deploy swarm-remove swarm-ps swarm-services swarm-logs swarm-update swarm-scale swarm-status

setup: ## Initialize submodules
	git submodule update --init --recursive

env: ## Copy .env.example to .env for configuration
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Environment file created. Please edit .env to configure your CKAN instance."; \
	else \
		echo ".env file already exists. Skipping copy."; \
	fi

help: ## Show this help message
	@echo "CKAN Docker Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Stack Management Commands
up: env ## Start CKAN stack in production mode (one command to start all)
	docker compose up -d

dev: env ## Start CKAN stack in development mode
	docker compose -f docker-compose.dev.yml up -d

build-images: build-all ## Build both CKAN base and dev images for local development
	@echo "All CKAN images built successfully and ready for local development!"

restart: ## Restart the CKAN stack
	docker compose restart

stop: ## Stop the CKAN stack
	docker compose down

logs: ## Show logs from all services
	docker compose logs -f

status: ## Show status of all services
	docker compose ps

# Image Build Commands (kept for reference)
build-base: ## Build CKAN base image (ckan/ckan-base:$(VERSION))
	cd $(CKAN_IMAGE_DIR) && ./build.sh build $(VERSION) base

build-dev: ## Build CKAN dev image (ckan/ckan-dev:$(VERSION))
	cd $(CKAN_IMAGE_DIR) && ./build.sh build $(VERSION) dev

build-all: build-base build-dev ## Build both CKAN base and dev images ($(VERSION))
	@echo "Both CKAN base and dev images built successfully!"

# Docker Swarm Commands
swarm-init: ## Initialize Docker Swarm mode
	@./bin/swarm-dev init

swarm-build: ## Build Docker images for swarm deployment
	@./bin/swarm-dev build

swarm-deploy: ## Deploy CKAN stack in Docker Swarm mode
	@./bin/swarm-dev deploy

swarm-remove: ## Remove CKAN stack from Docker Swarm
	@./bin/swarm-dev remove

swarm-ps: ## Show Docker Swarm stack tasks/containers
	@./bin/swarm-dev ps

swarm-services: ## Show Docker Swarm stack services
	@./bin/swarm-dev services

swarm-logs: ## Show logs from a swarm service (usage: make swarm-logs SERVICE=ckan-dev)
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make swarm-logs SERVICE=<service_name>"; \
		echo "Available services: ckan-dev, db, solr, redis, datapusher"; \
	else \
		./bin/swarm-dev logs $(SERVICE); \
	fi

swarm-update: ## Force update the CKAN development service in swarm
	@./bin/swarm-dev update

swarm-scale: ## Scale a swarm service (usage: make swarm-scale SERVICE=redis REPLICAS=2)
	@if [ -z "$(SERVICE)" ] || [ -z "$(REPLICAS)" ]; then \
		echo "Usage: make swarm-scale SERVICE=<service_name> REPLICAS=<number>"; \
	else \
		./bin/swarm-dev scale $(SERVICE) $(REPLICAS); \
	fi

swarm-status: ## Show overall Docker Swarm and stack status
	@./bin/swarm-dev status
