# AWS Bedrock Inference Profile Module

This module provides a Terraform resource for managing an Amazon Bedrock Inference Profile, which allows you to track metrics and costs for specific AI models, enabling better cost allocation and usage monitoring across different projects or use cases.

## Features

- **Cost Allocation**: Track costs for specific AI models across different projects
- **Usage Monitoring**: Monitor metrics and usage patterns for inference profiles
- **Project Tracking**: Use tags for detailed cost allocation and project management
- **Model Flexibility**: Support for both foundation models and cross-account inference profiles
- **Timeout Configuration**: Customizable timeouts for create, update, and delete operations

## Usage

### Basic Example

```hcl
data "aws_caller_identity" "current" {}

module "bedrock_inference_profile" {
  source = "./modules/aws-bedrock-inference-profile"

  name        = "Claude Sonnet for Project 123"
  description = "Profile with tag for cost allocation tracking"

  model_source = {
    copy_from = "arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
  }

  tags = {
    ProjectID   = "123"
    Environment = "production"
    Team        = "ai-platform"
  }
}
```

### Cross-Account Inference Profile Example

```hcl
data "aws_caller_identity" "current" {}

module "cross_account_inference_profile" {
  source = "./modules/aws-bedrock-inference-profile"

  name        = "Cross-Account Claude Profile"
  description = "Inference profile referencing another account's profile"

  model_source = {
    copy_from = "arn:aws:bedrock:eu-central-1:${data.aws_caller_identity.current.account_id}:inference-profile/eu.anthropic.claude-3-5-sonnet-20240620-v1:0"
  }

  tags = {
    ProjectID    = "cross-account-ai"
    Environment  = "production"
    CostCenter   = "engineering"
    Department   = "ai-research"
  }
}
```

### Advanced Example with Custom Timeouts

```hcl
module "bedrock_inference_profile_advanced" {
  source = "./modules/aws-bedrock-inference-profile"

  name        = "Advanced AI Model Profile"
  description = "Production profile for advanced AI workloads with extended timeouts"

  model_source = {
    copy_from = "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-opus-20240229-v1:0"
  }

  timeouts = {
    create = "10m"
    update = "8m"
    delete = "10m"
  }

  tags = {
    ProjectID     = "advanced-ai"
    Environment   = "production"
    Team          = "ml-engineering"
    CostCenter    = "research-development"
    Criticality   = "high"
    Backup        = "required"
  }
}
```

### Multiple Profiles for Different Use Cases

```hcl
# Development profile
module "dev_inference_profile" {
  source = "./modules/aws-bedrock-inference-profile"

  name        = "Development Claude Profile"
  description = "Development environment inference profile"

  model_source = {
    copy_from = "arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
  }

  tags = {
    Environment = "development"
    ProjectID   = "dev-testing"
    Team        = "development"
  }
}

# Production profile
module "prod_inference_profile" {
  source = "./modules/aws-bedrock-inference-profile"

  name        = "Production Claude Profile"
  description = "Production environment inference profile"

  model_source = {
    copy_from = "arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
  }

  tags = {
    Environment = "production"
    ProjectID   = "prod-services"
    Team        = "platform"
    Criticality = "high"
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
| [aws_bedrock_inference_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_inference_profile) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the inference profile. Must be unique within the AWS account. | `string` | n/a | yes |
| model_source | The source of the model this inference profile will track metrics and cost for. | `object({copy_from=string})` | n/a | yes |
| description | The description of the inference profile. | `string` | `null` | no |
| tags | Key-value mapping of resource tags for the inference profile. | `map(string)` | `{}` | no |
| timeouts | Configuration options for timeouts. | `object({create=string,update=string,delete=string})` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The Amazon Resource Name (ARN) of the inference profile |
| id | The unique identifier of the inference profile |
| name | The name of the inference profile |
| description | The description of the inference profile |
| status | The status of the inference profile |
| type | The type of the inference profile |
| models | A list of information about each model in the inference profile |
| created_at | The time at which the inference profile was created |
| updated_at | The time at which the inference profile was last updated |
| tags_all | A map of tags assigned to the resource |

## Import

In Terraform v1.5.0 and later, use an import block to import Bedrock Inference Profile using the name:

```hcl
import {
  to = aws_bedrock_inference_profile.example
  id = "inference_profile-id-12345678"
}
```

Using terraform import, import Bedrock Inference Profile using the name:

```bash
terraform import aws_bedrock_inference_profile.example inference_profile-id-12345678
```

## Common Model ARNs

### Foundation Models

#### Anthropic Claude Models
```
# Claude 3.5 Sonnet (Latest)
arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0

# Claude 3 Opus
arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-opus-20240229-v1:0

# Claude 3 Haiku
arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-haiku-20240307-v1:0
```

#### Amazon Titan Models
```
# Titan Text Express
arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-text-express-v1

# Titan Text Lite
arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-text-lite-v1
```

### Cross-Account Inference Profiles
```
# Example format for cross-account profiles
arn:aws:bedrock:eu-central-1:123456789012:inference-profile/eu.anthropic.claude-3-5-sonnet-20240620-v1:0
```

## Use Cases

### Cost Allocation
- Track AI costs by project, team, or department
- Allocate inference costs to specific cost centers
- Monitor usage patterns across different environments

### Project Management
- Separate profiles for different projects or applications
- Environment-specific profiles (dev, staging, production)
- Team-based cost tracking and monitoring

### Compliance and Governance
- Track usage for audit and compliance purposes
- Monitor AI model usage across the organization
- Implement cost controls and budgets per profile

## License

This module is licensed under the MIT License.
