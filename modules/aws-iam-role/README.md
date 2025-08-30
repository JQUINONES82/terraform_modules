# AWS IAM Role Terraform Module

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 5.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)
- [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)

## Inputs

The following input variables are supported:

### Required

- <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy)

  Description: Policy that grants an entity permission to assume the role

  Type: `string`

### Optional

- <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile)

  Description: Whether to create an instance profile for the role (useful for EC2)

  Type: `bool`

  Default: `false`

- <a name="input_create_role"></a> [create\_role](#input\_create\_role)

  Description: Whether to create the IAM role

  Type: `bool`

  Default: `true`

- <a name="input_description"></a> [description](#input\_description)

  Description: Description of the role

  Type: `string`

  Default: `null`

- <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies)

  Description: Whether to force detaching any policies the role has before destroying it

  Type: `bool`

  Default: `false`

- <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies)

  Description: Map of inline policies to attach to the role

  Type:

  ```hcl
  map(object({
    policy = string
  }))
  ```

  Default: `{}`

- <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name)

  Description: Name of the instance profile. If not provided, role name will be used

  Type: `string`

  Default: `null`

- <a name="input_instance_profile_path"></a> [instance\_profile\_path](#input\_instance\_profile\_path)

  Description: Path for the instance profile

  Type: `string`

  Default: `"/"`

- <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns)

  Description: Set of exclusive IAM managed policy ARNs to attach to the IAM role

  Type: `set(string)`

  Default: `[]`

- <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration)

  Description: Maximum session duration (in seconds) that you want to set for the specified role

  Type: `number`

  Default: `3600`

- <a name="input_name"></a> [name](#input\_name)

  Description: Friendly name of the role. If omitted, Terraform will assign a random, unique name

  Type: `string`

  Default: `null`

- <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix)

  Description: Creates a unique friendly name beginning with the specified prefix. Conflicts with name

  Type: `string`

  Default: `null`

- <a name="input_path"></a> [path](#input\_path)

  Description: Path to the role

  Type: `string`

  Default: `"/"`

- <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary)

  Description: ARN of the policy that is used to set the permissions boundary for the role

  Type: `string`

  Default: `null`

- <a name="input_tags"></a> [tags](#input\_tags)

  Description: Key-value mapping of tags for the IAM role

  Type: `map(string)`

  Default: `{}`

## Outputs

The following outputs are exported:

### General

- <a name="output_arn"></a> [arn](#output\_arn)

  Description: Amazon Resource Name (ARN) specifying the role

- <a name="output_assume_role_policy"></a> [assume\_role\_policy](#output\_assume\_role\_policy)

  Description: Policy document associated with the role

- <a name="output_create_date"></a> [create\_date](#output\_create\_date)

  Description: Creation date of the IAM role

- <a name="output_id"></a> [id](#output\_id)

  Description: Name of the role

- <a name="output_inline_policy_names"></a> [inline\_policy\_names](#output\_inline\_policy\_names)

  Description: List of inline policy names attached to the role

- <a name="output_managed_policy_arns"></a> [managed\_policy\_arns](#output\_managed\_policy\_arns)

  Description: Set of managed policy ARNs attached to the role

- <a name="output_max_session_duration"></a> [max\_session\_duration](#output\_max\_session\_duration)

  Description: Maximum session duration (in seconds) for the role

- <a name="output_name"></a> [name](#output\_name)

  Description: Name of the role

- <a name="output_path"></a> [path](#output\_path)

  Description: Path of the role

- <a name="output_permissions_boundary"></a> [permissions\_boundary](#output\_permissions\_boundary)

  Description: The ARN of the permissions boundary for the role

- <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all)

  Description: Map of tags assigned to the resource, including those inherited from the provider default_tags

- <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id)

  Description: Stable and unique string identifying the role

### Instance Profile

- <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn)

  Description: ARN assigned by AWS to the instance profile

- <a name="output_instance_profile_id"></a> [instance\_profile\_id](#output\_instance\_profile\_id)

  Description: Instance profile's ID

- <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name)

  Description: Name of the instance profile

- <a name="output_instance_profile_unique_id"></a> [instance\_profile\_unique\_id](#output\_instance\_profile\_unique\_id)

  Description: Unique ID assigned by AWS to the instance profile

<!-- markdownlint-enable MD033 -->

## Examples

### Basic Usage

Create a simple IAM role for EC2 instances:

```hcl
module "ec2_role" {
  source = "../../"

  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  create_instance_profile = true

  tags = {
    Environment = "dev"
    Purpose     = "ec2-access"
  }
}
```

### Lambda Execution Role

Create an IAM role for Lambda function execution:

```hcl
module "lambda_role" {
  source = "../../"

  name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policies = {
    s3_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::my-bucket/*"
          }
        ]
      })
    }
  }

  tags = {
    Environment = "prod"
    Service     = "lambda"
  }
}
```

### Cross-Account Role with Permissions Boundary

Create a role that can be assumed by another AWS account with a permissions boundary:

```hcl
module "cross_account_role" {
  source = "../../"

  name = "cross-account-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "unique-external-id"
          }
        }
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::123456789012:policy/DeveloperBoundary"
  max_session_duration = 7200  # 2 hours

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Environment = "prod"
    Purpose     = "cross-account-access"
  }
}
```

## Features

- **Comprehensive IAM Role Management**: Support for all IAM role configurations including assume role policies, managed policies, inline policies, and instance profiles
- **AWS Best Practices**: Uses separate policy attachment resources instead of deprecated inline policy management
- **Flexible Policy Management**: Support for both AWS managed policies and custom managed policies
- **Instance Profile Support**: Optional EC2 instance profile creation for roles that need to be used with EC2 instances
- **Validation**: Input validation for policy JSON, ARNs, paths, and session durations
- **Lifecycle Management**: Proper resource lifecycle management with create_before_destroy
- **Comprehensive Outputs**: All relevant resource attributes available as outputs
- **Tagging Support**: Full tagging support for compliance and cost allocation
- **Timeouts Configuration**: Configurable timeouts for resource operations

## Security Considerations

- Always follow the principle of least privilege when defining policies
- Use permissions boundaries for delegated administration scenarios
- Consider using external IDs for cross-account roles to prevent confused deputy attacks
- Regularly review and audit role permissions
- Use proper session duration limits based on your security requirements
- Enable CloudTrail logging to monitor role usage

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/LICENSE) for full details.
