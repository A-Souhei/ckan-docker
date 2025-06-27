# Makefile for CKAN Docker project

.PHONY: build-base build-dev build-all help

help: ## Show this help message
	@echo "CKAN Docker Build Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build-base: ## Build CKAN base image (ckan/ckan-base:2.11)
	cd ckan-docker-base && ./build.sh build 2.11 base

build-dev: ## Build CKAN dev image (ckan/ckan-dev:2.11)
	cd ckan-docker-base && ./build.sh build 2.11 dev

build-all: build-base build-dev ## Build both CKAN base and dev images (2.11)
	@echo "Both CKAN base and dev images built successfully!"
