# Basic KMS Key Example

This example demonstrates the basic usage of the AWS KMS Key module.

## What This Example Does

This example creates:
- A basic KMS key with encryption/decryption capabilities
- Automatic key rotation enabled
- Basic tags for resource management

## Usage

1. Ensure you have AWS credentials configured
2. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Clean Up

To destroy the resources:

```bash
terraform destroy
```

## Outputs

- `key_id` - The KMS key ID
- `key_arn` - The KMS key ARN
- `key_state` - The current state of the key
