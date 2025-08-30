.PHONY: help init validate plan apply destroy fmt docs test clean all

# Variables
TF_VAR_FILE ?= terraform.tfvars
EXAMPLE_DIR ?= examples/basic

# Default target
all: fmt validate test

help: ## Show this help message
	@echo 'Usage: make [TARGET] [VARIABLES]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Variables:'
	@echo '  EXAMPLE_DIR     Directory containing example (default: examples/basic)'
	@echo '  TF_VAR_FILE     Terraform variables file (default: terraform.tfvars)'

init: ## Initialize Terraform
	@echo "Initializing Terraform in $(EXAMPLE_DIR)..."
	@cd $(EXAMPLE_DIR) && terraform init

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@terraform validate
	@echo "Validating example in $(EXAMPLE_DIR)..."
	@cd $(EXAMPLE_DIR) && terraform validate

plan: init ## Plan Terraform deployment
	@echo "Planning Terraform deployment in $(EXAMPLE_DIR)..."
	@cd $(EXAMPLE_DIR) && terraform plan -var-file=$(TF_VAR_FILE)

apply: init ## Apply Terraform configuration
	@echo "Applying Terraform configuration in $(EXAMPLE_DIR)..."
	@cd $(EXAMPLE_DIR) && terraform apply -var-file=$(TF_VAR_FILE) -auto-approve

destroy: ## Destroy Terraform resources
	@echo "Destroying Terraform resources in $(EXAMPLE_DIR)..."
	@cd $(EXAMPLE_DIR) && terraform destroy -var-file=$(TF_VAR_FILE) -auto-approve

fmt: ## Format Terraform code
	@echo "Formatting Terraform code..."
	@terraform fmt -recursive .

docs: ## Generate documentation
	@echo "Generating documentation..."
	@which terraform-docs > /dev/null || (echo "terraform-docs not found. Please install it." && exit 1)
	@terraform-docs markdown table --output-file README.md .

test: ## Run tests
	@echo "Running tests..."
	@cd test && go test -v -timeout 30m

test-init: ## Initialize test dependencies
	@echo "Initializing test dependencies..."
	@cd test && go mod init test && go mod tidy

clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.tfplan" -delete
	@find . -type f -name "*.tfstate*" -delete
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true

lint: ## Run linting tools
	@echo "Running Terraform linting..."
	@which tflint > /dev/null || (echo "tflint not found. Please install it." && exit 1)
	@tflint

security: ## Run security checks
	@echo "Running security checks..."
	@which tfsec > /dev/null || (echo "tfsec not found. Please install it." && exit 1)
	@tfsec .

validate-examples: ## Validate all examples
	@echo "Validating all examples..."
	@for dir in examples/*/; do \
		echo "Validating $$dir..."; \
		cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
	done

# Development targets
dev-init: ## Initialize development environment
	@echo "Initializing development environment..."
	@make init EXAMPLE_DIR=examples/basic
	@make test-init

dev-validate: ## Run full validation suite
	@echo "Running full validation suite..."
	@make fmt
	@make validate
	@make validate-examples
	@make lint
	@make security

# CI/CD targets
ci: ## Run CI pipeline
	@echo "Running CI pipeline..."
	@make fmt
	@make validate
	@make validate-examples
	@make test

cd: ## Run CD pipeline
	@echo "Running CD pipeline..."
	@make apply EXAMPLE_DIR=examples/basic
