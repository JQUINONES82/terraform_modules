# AWS Bedrock Guardrail Module

This module provides a Terraform resource for managing an Amazon Bedrock Guardrail, which helps control and filter content in AI-powered applications by defining policies for content filtering, sensitive information protection, topic restrictions, and word filtering.

## Features

- **Content Policy Configuration**: Filter content based on harmful categories like hate speech, violence, sexual content, etc.
- **Sensitive Information Protection**: Detect and handle PII entities and custom regex patterns
- **Topic Policy Configuration**: Define and restrict specific topics in conversations
- **Word Policy Configuration**: Block or filter specific words using managed lists or custom words
- **Contextual Grounding**: Ensure model responses are grounded and relevant to the context
- **Cross-Region Support**: Enable cross-region routing for guardrails

## Usage

### Basic Example

```hcl
module "bedrock_guardrail" {
  source = "./modules/aws-bedrock-guardrail"

  name                      = "example-guardrail"
  blocked_input_messaging   = "Your input has been blocked due to policy violations."
  blocked_outputs_messaging = "The response has been blocked due to policy violations."
  description              = "Example guardrail for content filtering"

  content_policy_config = {
    filters_config = [
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type           = "HATE"
      },
      {
        input_strength  = "HIGH"
        output_strength = "HIGH"
        type           = "VIOLENCE"
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  tags = {
    Environment = "production"
    Team        = "ai-platform"
  }
}
```

### Advanced Example with All Policies

```hcl
module "comprehensive_guardrail" {
  source = "./modules/aws-bedrock-guardrail"

  name                      = "comprehensive-guardrail"
  blocked_input_messaging   = "Your input violates our content policy."
  blocked_outputs_messaging = "The AI response has been filtered for policy compliance."
  description              = "Comprehensive guardrail with all policy types"

  # Content filtering
  content_policy_config = {
    filters_config = [
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type           = "HATE"
      },
      {
        input_strength  = "HIGH"
        output_strength = "HIGH"
        type           = "VIOLENCE"
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  # Sensitive information protection
  sensitive_information_policy_config = {
    pii_entities_config = [
      {
        action = "BLOCK"
        type   = "NAME"
      },
      {
        action = "ANONYMIZE"
        type   = "EMAIL"
      }
    ]
    regexes_config = [
      {
        action      = "BLOCK"
        description = "Social Security Number pattern"
        name        = "ssn_pattern"
        pattern     = "^\\d{3}-\\d{2}-\\d{4}$"
      }
    ]
  }

  # Topic restrictions
  topic_policy_config = {
    topics_config = [
      {
        name       = "investment_advice"
        examples   = ["Where should I invest my money?", "What stocks should I buy?"]
        type       = "DENY"
        definition = "Investment advice refers to inquiries, guidance, or recommendations regarding financial investments."
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  # Word filtering
  word_policy_config = {
    managed_word_lists_config = [
      {
        type = "PROFANITY"
      }
    ]
    words_config = [
      {
        text = "inappropriate_word"
      }
    ]
  }

  tags = {
    Environment = "production"
    Team        = "ai-platform"
    Purpose     = "content-filtering"
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
| [aws_bedrock_guardrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_guardrail) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the guardrail. Must be unique within the AWS account. | `string` | n/a | yes |
| blocked_input_messaging | Message to return when the guardrail blocks a prompt. | `string` | n/a | yes |
| blocked_outputs_messaging | Message to return when the guardrail blocks a model response. | `string` | n/a | yes |
| description | Description of the guardrail or its version. | `string` | `null` | no |
| kms_key_arn | The KMS key with which the guardrail was encrypted at rest. | `string` | `null` | no |
| tags | Key-value map of resource tags. | `map(string)` | `{}` | no |
| content_policy_config | Content policy config for content filtering | `object` | `null` | no |
| contextual_grounding_policy_config | Contextual grounding policy config | `object` | `null` | no |
| sensitive_information_policy_config | Sensitive information policy config | `object` | `null` | no |
| topic_policy_config | Topic policy config for topic restrictions | `object` | `null` | no |
| word_policy_config | Word policy config for word filtering | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| guardrail_id | The unique identifier of the guardrail |
| guardrail_arn | The Amazon Resource Name (ARN) of the guardrail |
| name | The name of the guardrail |
| description | The description of the guardrail |
| version | The version of the guardrail |
| status | The status of the guardrail |
| created_at | The date and time at which the guardrail was created |
| tags_all | A map of tags assigned to the resource |

## License

This module is licensed under the MIT License.
