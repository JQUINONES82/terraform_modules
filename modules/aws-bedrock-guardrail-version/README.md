# AWS Bedrock Guardrail Version Module

This module provides a Terraform resource for managing an Amazon Bedrock Guardrail Version, which allows you to create versioned snapshots of guardrail configurations for better deployment management and rollback capabilities in AI-powered applications.

## Features

- **Version Management**: Create versioned snapshots of guardrail configurations
- **Deployment Control**: Enable controlled deployments with version-specific configurations
- **Rollback Support**: Maintain previous versions for rollback scenarios
- **Retention Options**: Configure whether to retain versions during destroy operations
- **Timeout Configuration**: Customizable timeouts for create and delete operations

## Usage

### Basic Example

```hcl
# First create a guardrail
module "bedrock_guardrail" {
  source = "../aws-bedrock-guardrail"

  name                      = "example-guardrail"
  blocked_input_messaging   = "Input blocked"
  blocked_outputs_messaging = "Output blocked"

  content_policy_config = {
    filters_config = [{
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
      type           = "HATE"
    }]
    tier_config = {
      tier_name = "STANDARD"
    }
  }
}

# Then create a version
module "guardrail_version" {
  source = "./modules/aws-bedrock-guardrail-version"

  guardrail_arn = module.bedrock_guardrail.guardrail_arn
  description   = "Initial version with hate speech filtering"
}
```

### Advanced Example with Custom Timeouts

```hcl
module "guardrail_version_with_retention" {
  source = "./modules/aws-bedrock-guardrail-version"

  guardrail_arn = var.guardrail_arn
  description   = "Production version v2.1 - Enhanced content filtering"
  skip_destroy  = true  # Retain this version for rollback

  timeouts = {
    create = "10m"
    delete = "10m"
  }
}
```

### Multiple Versions for Different Environments

```hcl
# Development version
module "guardrail_version_dev" {
  source = "./modules/aws-bedrock-guardrail-version"

  guardrail_arn = var.guardrail_arn
  description   = "Development version - Testing new policies"
  skip_destroy  = false
}

# Staging version
module "guardrail_version_staging" {
  source = "./modules/aws-bedrock-guardrail-version"

  guardrail_arn = var.guardrail_arn
  description   = "Staging version - Pre-production validation"
  skip_destroy  = true
}

# Production version
module "guardrail_version_prod" {
  source = "./modules/aws-bedrock-guardrail-version"

  guardrail_arn = var.guardrail_arn
  description   = "Production version - Stable release"
  skip_destroy  = true

  timeouts = {
    create = "15m"
    delete = "15m"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrock_guardrail_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_guardrail_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| guardrail_arn | Guardrail ARN. This is the Amazon Resource Name of the guardrail for which you want to create a version. | `string` | n/a | yes |
| description | Description of the Guardrail version. Provides context about what changes or improvements are included in this version. | `string` | `null` | no |
| skip_destroy | Whether to retain the old version of a previously deployed Guardrail when this resource is destroyed. | `bool` | `false` | no |
| timeouts | Configuration options for timeouts. | `object({create=string,delete=string})` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| version | The version number of the guardrail version |
| guardrail_arn | The Amazon Resource Name (ARN) of the guardrail |
| description | The description of the guardrail version |
| skip_destroy | Whether the guardrail version will be retained during destroy operations |
| id | The ID of the guardrail version resource |

## Import

In Terraform v1.5.0 and later, use an import block to import Amazon Bedrock Guardrail Version using a comma-delimited string of guardrail_arn and version:

```hcl
import {
  to = aws_bedrock_guardrail_version.example
  id = "arn:aws:bedrock:us-west-2:123456789012:guardrail-id-12345678,1"
}
```

Using terraform import, import Amazon Bedrock Guardrail Version using a comma-delimited string of guardrail_arn and version:

```bash
terraform import aws_bedrock_guardrail_version.example "arn:aws:bedrock:us-west-2:123456789012:guardrail-id-12345678,1"
```

## Use Cases

### Version Management Strategy

1. **Development Versions**: Create versions with `skip_destroy = false` for testing
2. **Staging Versions**: Create versions with `skip_destroy = true` for validation
3. **Production Versions**: Always use `skip_destroy = true` to enable rollbacks

### Deployment Pipeline Integration

```hcl
# CI/CD Pipeline example
module "guardrail_version_release" {
  source = "./modules/aws-bedrock-guardrail-version"

  guardrail_arn = var.guardrail_arn
  description   = "Release ${var.release_version} - ${var.release_notes}"
  skip_destroy  = var.environment == "production" ? true : false
}
```

## License

This module is licensed under the MIT License.
