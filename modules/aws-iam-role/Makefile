.PHONY: fmt validate docs test clean
.DEFAULT_GOAL := help

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

fmt: ## Format Terraform code
	terraform fmt -recursive

validate: ## Validate Terraform configuration
	terraform init -backend=false
	terraform validate

plan: ## Create Terraform plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy Terraform resources
	terraform destroy

docs: ## Generate documentation
	terraform-docs markdown table --output-file README.md --output-mode inject .

test: ## Run tests
	cd test && go mod download && go test -v -timeout 30m

test-init: ## Initialize test dependencies
	cd test && go mod init test && go mod tidy

clean: ## Clean temporary files
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -rf terraform.tfstate*
	rm -rf test/go.mod test/go.sum

security: ## Run security scan
	checkov -f main.tf
	tfsec .

lint: ## Run linting
	tflint --init
	tflint

all: fmt validate docs ## Run format, validate, and docs
