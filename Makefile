# Makefile for CKAN Docker project

# CKAN version to build
VERSION ?= 2.11

# Directory containing CKAN image build scripts
CKAN_IMAGE_DIR = ckan-docker-base

# Default goal - show help when running 'make' without arguments
.DEFAULT_GOAL := help

.PHONY: build-base build-dev build-all help setup

setup: ## Initialize submodules
	git submodule update --init --recursive

help: ## Show this help message
	@echo "CKAN Docker Build Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build-base: ## Build CKAN base image (ckan/ckan-base:$(VERSION))
	cd $(CKAN_IMAGE_DIR) && ./build.sh build $(VERSION) base

build-dev: ## Build CKAN dev image (ckan/ckan-dev:$(VERSION))
	cd $(CKAN_IMAGE_DIR) && ./build.sh build $(VERSION) dev

build-all: build-base build-dev ## Build both CKAN base and dev images ($(VERSION))
	@echo "Both CKAN base and dev images built successfully!"
