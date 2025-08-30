.PHONY: help init validate plan apply destroy test clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init       - Initialize Terraform"
	@echo "  validate   - Validate Terraform configuration"
	@echo "  plan       - Create Terraform execution plan"
	@echo "  apply      - Apply Terraform configuration"
	@echo "  destroy    - Destroy Terraform-managed infrastructure"
	@echo "  test       - Run integration tests"
	@echo "  clean      - Clean up temporary files"

# Initialize Terraform
init:
	terraform init

# Validate configuration
validate: init
	terraform validate

# Create execution plan
plan: validate
	terraform plan

# Apply configuration
apply: validate
	terraform apply

# Destroy infrastructure
destroy:
	terraform destroy

# Run tests
test:
	cd test && go test -v -timeout 30m -tags=integration

# Clean up
clean:
	rm -rf .terraform/
	rm -f *.tfstate
	rm -f *.tfstate.backup
	rm -f *.tfplan
	rm -f .terraform.lock.hcl
