SHELL := /bin/bash

# Dirpaths for images
POSTGRES_DIR := packer/postgres

######################
# Make Targets
######################
.PHONY: help
help: ## Show this help message.
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "; printf "\nUsage:\n"}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo

######################
# Packer Targets
######################

# Postgres

.PHONY: publish-postgres
publish-postgres: ## Build and Publish the Nutanix Image.
	@cd $(POSTGRES_DIR) && packer init .
	@cd $(POSTGRES_DIR) && packer build .

.PHONY: build-postgres
build-postgres: ## Build the Nutanix Image.
	@cd $(POSTGRES_DIR) && packer init .
	@cd $(POSTGRES_DIR) && packer build -var "image_delete=true" .

.PHONY: fmt-postgres
fmt-postgres: ## Run packer fmt for the Nutanix Image.
	@cd $(POSTGRES_DIR) && packer fmt .

.PHONY: validate-postgres
validate-postgres: ## Run packer validation for the Nutanix Image.
	@cd $(POSTGRES_DIR) && packer init .
	@cd $(POSTGRES_DIR) && packer validate .
