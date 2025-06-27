# Makefile for CKAN Docker project

# CKAN version to build
VERSION ?= 2.11

# Directory containing CKAN image build scripts
CKAN_IMAGE_DIR = ckan-docker-base

# Default goal - show help when running 'make' without arguments
.DEFAULT_GOAL := help

.PHONY: build-base build-dev build-all help setup up dev restart stop logs status env

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
