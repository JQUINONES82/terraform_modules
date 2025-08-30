# AWS IAM Policy Terraform Module

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

- [aws_iam_group_policy_attachment.group_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) (resource)
- [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
- [aws_iam_policy_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_version) (resource)
- [aws_iam_role_policy_attachment.role_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_user_policy_attachment.user_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) (resource)

## Inputs

The following input variables are supported:

### Required

- <a name="input_policy"></a> [policy](#input\_policy)

  Description: The policy document as a JSON string

  Type: `string`

### Optional

- <a name="input_attach_to_groups"></a> [attach\_to\_groups](#input\_attach\_to\_groups)

  Description: List of IAM group names to attach this policy to

  Type: `list(string)`

  Default: `[]`

- <a name="input_attach_to_roles"></a> [attach\_to\_roles](#input\_attach\_to\_roles)

  Description: List of IAM role names to attach this policy to

  Type: `list(string)`

  Default: `[]`

- <a name="input_attach_to_users"></a> [attach\_to\_users](#input\_attach\_to\_users)

  Description: List of IAM user names to attach this policy to

  Type: `list(string)`

  Default: `[]`

- <a name="input_create_policy"></a> [create\_policy](#input\_create\_policy)

  Description: Whether to create the IAM policy

  Type: `bool`

  Default: `true`

- <a name="input_description"></a> [description](#input\_description)

  Description: Description of the IAM policy

  Type: `string`

  Default: `null`

- <a name="input_name"></a> [name](#input\_name)

  Description: The name of the policy. If omitted, Terraform will assign a random, unique name

  Type: `string`

  Default: `null`

- <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix)

  Description: Creates a unique name beginning with the specified prefix. Conflicts with name

  Type: `string`

  Default: `null`

- <a name="input_path"></a> [path](#input\_path)

  Description: Path in which to create the policy

  Type: `string`

  Default: `"/"`

- <a name="input_policy_versions"></a> [policy\_versions](#input\_policy\_versions)

  Description: Map of policy versions to create. Key is version identifier, value is policy document and default flag

  Type:

  ```hcl
  map(object({
    policy_document = string
    set_as_default  = bool
  }))
  ```

  Default: `null`

- <a name="input_tags"></a> [tags](#input\_tags)

  Description: Key-value mapping of tags for the IAM policy

  Type: `map(string)`

  Default: `{}`

## Outputs

The following outputs are exported:

### Policy Details

- <a name="output_arn"></a> [arn](#output\_arn)

  Description: The ARN assigned by AWS to this policy

- <a name="output_attachment_count"></a> [attachment\_count](#output\_attachment\_count)

  Description: Total number of attachments (roles + users + groups)

- <a name="output_attached_groups"></a> [attached\_groups](#output\_attached\_groups)

  Description: List of groups this policy is attached to

- <a name="output_attached_roles"></a> [attached\_roles](#output\_attached\_roles)

  Description: List of roles this policy is attached to

- <a name="output_attached_users"></a> [attached\_users](#output\_attached\_users)

  Description: List of users this policy is attached to

- <a name="output_description"></a> [description](#output\_description)

  Description: The description of the policy

- <a name="output_id"></a> [id](#output\_id)

  Description: The policy ID

- <a name="output_name"></a> [name](#output\_name)

  Description: The name of the policy

- <a name="output_path"></a> [path](#output\_path)

  Description: The path of the policy in IAM

- <a name="output_policy"></a> [policy](#output\_policy)

  Description: The policy document

- <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id)

  Description: The policy's ID

- <a name="output_policy_versions"></a> [policy\_versions](#output\_policy\_versions)

  Description: Map of policy versions created

- <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all)

  Description: A map of tags assigned to the resource, including those inherited from the provider default_tags

<!-- markdownlint-enable MD033 -->

## Examples

### Basic Policy Creation

Create a simple IAM policy for S3 read access:

```hcl
module "s3_read_policy" {
  source = "../../"

  name        = "s3-read-only-policy"
  description = "Allows read access to specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })

  tags = {
    Environment = "prod"
    Service     = "s3"
  }
}
```

### Policy with Attachments

Create a policy and attach it to IAM entities:

```hcl
module "cloudwatch_policy" {
  source = "../../"

  name        = "cloudwatch-access-policy"
  description = "CloudWatch logs and metrics access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  # Attach to existing IAM entities
  attach_to_roles  = ["lambda-execution-role"]
  attach_to_users  = ["developer-user"]
  attach_to_groups = ["developers-group"]

  tags = {
    Environment = "prod"
    Service     = "cloudwatch"
  }
}
```

### Using aws_iam_policy_document Data Source

Best practice approach using data sources:

```hcl
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "S3Access"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::my-bucket/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
}

module "s3_policy" {
  source = "../../"

  name   = "s3-encrypted-access"
  policy = data.aws_iam_policy_document.s3_policy.json
}
```

### Complex Policy with Multiple Services

```hcl
module "comprehensive_policy" {
  source = "../../"

  name        = "application-policy"
  description = "Comprehensive policy for application needs"
  path        = "/application/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::app-bucket/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/app-table"
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:app/*"
      }
    ]
  })

  tags = {
    Environment = "prod"
    Application = "my-app"
  }
}
```

### Policy with Versions

Create a policy with multiple versions:

```hcl
module "versioned_policy" {
  source = "../../"

  name = "versioned-policy"

  # Initial policy version
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "*"
      }
    ]
  })

  # Additional policy versions
  policy_versions = {
    v2 = {
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = ["s3:GetObject", "s3:PutObject"]
            Resource = "*"
          }
        ]
      })
      set_as_default = false
    }
    v3 = {
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = ["s3:*"]
            Resource = "*"
          }
        ]
      })
      set_as_default = true
    }
  }
}
```

## Features

- **Comprehensive Policy Management**: Full support for AWS IAM policy features including policy versions
- **Automatic Attachments**: Built-in support for attaching policies to roles, users, and groups
- **Input Validation**: Extensive validation for policy documents, names, paths, and attachments
- **Policy Versioning**: Support for creating and managing multiple policy versions
- **Flexible Naming**: Support for explicit names or auto-generated names with prefixes
- **Path Management**: Support for organizing policies with custom paths
- **Lifecycle Management**: Proper resource lifecycle with create_before_destroy
- **Comprehensive Outputs**: All relevant policy attributes and attachment information
- **Data Source Integration**: Works seamlessly with aws_iam_policy_document data sources

## Best Practices

### Policy Document Creation

1. **Use Data Sources**: Prefer `aws_iam_policy_document` data source for complex policies
2. **Validate JSON**: Always ensure policy documents are valid JSON
3. **Size Limits**: Keep policy documents under 6144 characters
4. **Principle of Least Privilege**: Grant only necessary permissions

### Policy Organization

1. **Use Paths**: Organize policies with meaningful paths (e.g., `/application/`, `/service/`)
2. **Descriptive Names**: Use clear, descriptive policy names
3. **Comprehensive Descriptions**: Include detailed descriptions for policy purpose
4. **Consistent Tagging**: Apply consistent tags for governance and cost allocation

### Version Management

1. **Gradual Rollout**: Use policy versions for gradual permission changes
2. **Default Versions**: Carefully manage which version is set as default
3. **Version Limits**: AWS limits policies to 5 versions maximum
4. **Testing**: Test new policy versions before setting as default

### Security Considerations

1. **Condition Blocks**: Use condition blocks to restrict access appropriately
2. **Resource Specificity**: Specify resources explicitly rather than using wildcards
3. **Regular Audits**: Regularly review and audit policy permissions
4. **Attachment Tracking**: Monitor which entities have policies attached

## AWS IAM Policy Limits

- **Policy Document Size**: Maximum 6,144 characters
- **Policy Name Length**: 1-128 characters
- **Policy Versions**: Maximum 5 versions per policy
- **Path Length**: Maximum 512 characters
- **Description Length**: Maximum 1,000 characters

## Validation

The module includes comprehensive validation for:

- Policy document JSON syntax and size
- Policy name format and length
- Path format and structure
- Attachment entity name formats
- Policy version configurations

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/LICENSE) for full details.
