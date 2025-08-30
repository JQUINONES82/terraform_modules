SHELL := $(shell which bash)
.PHONY: test fmt validate docs clean lint all

test:
	@echo "Running integration tests..."
	pushd test; \
	go mod init "aws-vpc-endpoint"; \
	go mod tidy; \
	go test -v -tags integration -timeout 3600s; \
	popd

fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive .

validate:
	@echo "Validating Terraform configuration..."
	terraform init -backend=false
	terraform validate

docs:
	@echo "Generating documentation..."
	terraform-docs markdown table --output-file README.md --output-mode inject .

clean:
	@echo "Cleaning up..."
	find . -type f -name "terraform.tfstate*" -delete
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -delete

lint:
	@echo "Running TFLint..."
	tflint --init
	tflint .

all: fmt validate lint docs test
