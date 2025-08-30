# aws-s3-bucket

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

This module creates a comprehensive AWS S3 bucket with support for all major S3 features including versioning, encryption, lifecycle management, CORS, website hosting, notifications, and more.

## Features

- **Basic Bucket Management**: Create buckets with custom names or prefixes
- **Security & Access Control**: 
  - Public access blocking
  - Bucket policies
  - Object ownership controls
  - Server-side encryption with KMS
- **Lifecycle Management**: Comprehensive lifecycle rules with transitions and expiration
- **Website Hosting**: Static website configuration with routing rules
- **Cross-Origin Resource Sharing (CORS)**: Flexible CORS rule configuration
- **Notifications**: SNS, SQS, and Lambda function notifications
- **Performance**: Transfer acceleration support
- **Monitoring & Logging**: Access logging configuration
- **Advanced Features**: 
  - Intelligent tiering
  - Replication configuration
  - Request payment configuration

## Usage

### Basic Example

```hcl
module "basic_s3_bucket" {
  source = "path/to/aws-s3-bucket"

  bucket = "my-basic-bucket"
  
  tags = {
    Environment = "development"
    Project     = "example"
  }
}
```

### Comprehensive Example

```hcl
module "comprehensive_s3_bucket" {
  source = "path/to/aws-s3-bucket"

  bucket              = "my-comprehensive-bucket"
  force_destroy       = true
  object_lock_enabled = true

  # Security settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  # Encryption
  enable_server_side_encryption = true
  kms_master_key_id             = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Lifecycle management
  lifecycle_rules = [
    {
      id     = "log_transition"
      status = "Enabled"
      filter = {
        prefix = "logs/"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
    }
  ]

  # CORS configuration
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://example.com"]
      max_age_seconds = 3000
    }
  ]

  tags = {
    Environment = "production"
    Project     = "example"
  }
}
```

### Static Website Hosting

```hcl
module "website_bucket" {
  source = "path/to/aws-s3-bucket"

  bucket = "my-static-website"

  # Disable public access blocking for website
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # Website configuration
  website_configuration = {
    index_document = {
      suffix = "index.html"
    }
    error_document = {
      key = "error.html"
    }
  }

  # Public read policy
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::my-static-website/*"
      }
    ]
  })

  object_ownership = "BucketOwnerPreferred"
}
```

### Bucket Policy Examples

```hcl
# CloudFront Origin Access Control
module "cloudfront_bucket" {
  source = "path/to/aws-s3-bucket"

  bucket = "my-cloudfront-bucket"

  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::my-cloudfront-bucket/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::123456789012:distribution/EXAMPLE"
          }
        }
      }
    ]
  })
}

# Cross-account access with conditions
module "cross_account_bucket" {
  source = "path/to/aws-s3-bucket"

  bucket = "my-cross-account-bucket"

  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::TRUSTED-ACCOUNT-ID:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-cross-account-bucket/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      }
    ]
  })
}
```

## Examples

- [Basic](examples/simple/) - Simple S3 bucket with basic configuration
- [Comprehensive](examples/comprehensive/) - Full-featured S3 bucket with all options
- [Static Website](examples/static-website/) - S3 bucket configured for static website hosting
- [Bucket Policy](examples/bucket-policy/) - Various bucket policy scenarios including public access, CloudFront OAC, cross-account access, and conditional policies

## Testing

This module includes comprehensive tests using Terratest. To run the tests:

```bash
cd test
go test -v -timeout 30m -tags=integration
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_request_payment_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_request_payment_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Block public access to the bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Block public policy access to the bucket | `bool` | `true` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the S3 bucket to create | `string` | `null` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | IAM policy document for the bucket | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The prefix to use for the S3 bucket name | `string` | `null` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | List of CORS rules for the bucket | <pre>list(object({<br>    id              = optional(string)<br>    allowed_headers = optional(list(string))<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    expose_headers  = optional(list(string))<br>    max_age_seconds = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Enable replication for the bucket | `bool` | `true` | no |
| <a name="input_enable_server_side_encryption"></a> [enable\_server\_side\_encryption](#input\_enable\_server\_side\_encryption) | Enable server side encryption for the bucket | `bool` | `true` | no |
| <a name="input_enable_transfer_acceleration"></a> [enable\_transfer\_acceleration](#input\_enable\_transfer\_acceleration) | Enable transfer acceleration for the bucket | `bool` | `false` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | The expected owner of the bucket | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force destroy the bucket if it exists | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Ignore public acls for the bucket | `bool` | `true` | no |
| <a name="input_intelligent_tiering_configurations"></a> [intelligent\_tiering\_configurations](#input\_intelligent\_tiering\_configurations) | Map of intelligent tiering configurations | <pre>map(object({<br>    name   = string<br>    status = string<br>    filter = optional(object({<br>      prefix = optional(string)<br>      tags   = optional(map(string))<br>    }))<br>    tiering = list(object({<br>      access_tier = string<br>      days        = number<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The KMS key id to use for encryption | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle rules for the bucket | <pre>list(object({<br>    id     = string<br>    status = string<br>    filter = optional(object({<br>      prefix                   = optional(string)<br>      object_size_greater_than = optional(number)<br>      object_size_less_than    = optional(number)<br>      tags                     = optional(map(string))<br>    }))<br>    expiration = optional(object({<br>      days                         = optional(number)<br>      date                         = optional(string)<br>      expired_object_delete_marker = optional(bool)<br>    }))<br>    noncurrent_version_expiration = optional(object({<br>      noncurrent_days           = optional(number)<br>      newer_noncurrent_versions = optional(number)<br>    }))<br>    transitions = optional(list(object({<br>      days          = optional(number)<br>      date          = optional(string)<br>      storage_class = string<br>    })))<br>    noncurrent_version_transitions = optional(list(object({<br>      noncurrent_days           = number<br>      newer_noncurrent_versions = optional(number)<br>      storage_class             = string<br>    })))<br>    abort_incomplete_multipart_upload = optional(object({<br>      days_after_initiation = number<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Enable logging for the bucket | `bool` | `true` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | The target bucket for the logging configuration | `string` | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | The target prefix for the logging configuration | `string` | `null` | no |
| <a name="input_notification_configuration"></a> [notification\_configuration](#input\_notification\_configuration) | Notification configuration for the bucket | <pre>object({<br>    sns_topics = optional(list(object({<br>      topic_arn     = string<br>      events        = list(string)<br>      filter_prefix = optional(string)<br>      filter_suffix = optional(string)<br>    })))<br>    sqs_queues = optional(list(object({<br>      queue_arn     = string<br>      events        = list(string)<br>      filter_prefix = optional(string)<br>      filter_suffix = optional(string)<br>    })))<br>    lambda_functions = optional(list(object({<br>      lambda_function_arn = string<br>      events              = list(string)<br>      filter_prefix       = optional(string)<br>      filter_suffix       = optional(string)<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | Enable object lock for the bucket | `bool` | `false` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Object ownership setting for the bucket. Valid values: BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced | `string` | `null` | no |
| <a name="input_replication_role"></a> [replication\_role](#input\_replication\_role) | The role ARN to use for replication | `string` | `null` | no |
| <a name="input_replication_target_bucket"></a> [replication\_target\_bucket](#input\_replication\_target\_bucket) | The target bucket to use for replication | `string` | `null` | no |
| <a name="input_replication_token"></a> [replication\_token](#input\_replication\_token) | The token to use for replication | `string` | `null` | no |
| <a name="input_request_payer"></a> [request\_payer](#input\_request\_payer) | Specifies who should bear the cost of Amazon S3 data transfer. Valid values: BucketOwner, Requester | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Restrict public access to the bucket | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the bucket | `map(any)` | `null` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning for the bucket | `bool` | `true` | no |
| <a name="input_website_configuration"></a> [website\_configuration](#input\_website\_configuration) | Website configuration for the bucket | <pre>object({<br>    index_document = optional(object({<br>      suffix = string<br>    }))<br>    error_document = optional(object({<br>      key = string<br>    }))<br>    redirect_all_requests_to = optional(object({<br>      host_name = string<br>      protocol  = optional(string)<br>    }))<br>    routing_rules = optional(list(object({<br>      condition = optional(object({<br>        http_error_code_returned_equals = optional(string)<br>        key_prefix_equals               = optional(string)<br>      }))<br>      redirect = object({<br>        host_name               = optional(string)<br>        http_redirect_code      = optional(string)<br>        protocol                = optional(string)<br>        replace_key_prefix_with = optional(string)<br>        replace_key_with        = optional(string)<br>      })<br>    })))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region |
| <a name="output_id"></a> [id](#output\_id) | The name of the bucket |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this bucket resides in |
| <a name="output_result"></a> [result](#output\_result) | The result of the module. |
| <a name="output_website_domain"></a> [website\_domain](#output\_website\_domain) | The domain of the website endpoint, if the bucket is configured with a website |
| <a name="output_website_endpoint"></a> [website\_endpoint](#output\_website\_endpoint) | The website endpoint, if the bucket is configured with a website |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  EOT
  value       = module.this.result
}
```
<!-- markdownlint-disable -->

## Modules

No modules.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>5.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Block public access to the bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Block public policy access to the bucket | `bool` | `true` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the S3 bucket to create | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The prefix to use for the S3 bucket name | `string` | `null` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Enable replication for the bucket | `bool` | `true` | no |
| <a name="input_enable_server_side_encryption"></a> [enable\_server\_side\_encryption](#input\_enable\_server\_side\_encryption) | Enable server side encryption for the bucket | `bool` | `true` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | The expected owner of the bucket | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force destroy the bucket if it exists | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Ignore public acls for the bucket | `bool` | `true` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The KMS key id to use for encryption | `string` | `null` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Enable logging for the bucket | `bool` | `true` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | The target bucket for the logging configuration | `string` | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | The target prefix for the logging configuration | `string` | `null` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | Enable object lock for the bucket | `bool` | `false` | no |
| <a name="input_replication_role"></a> [replication\_role](#input\_replication\_role) | The role ARN to use for replication | `string` | `null` | no |
| <a name="input_replication_target_bucket"></a> [replication\_target\_bucket](#input\_replication\_target\_bucket) | The target bucket to use for replication | `string` | `null` | no |
| <a name="input_replication_token"></a> [replication\_token](#input\_replication\_token) | The token to use for replication | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Restrict public access to the bucket | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the bucket | `map(any)` | `null` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning for the bucket | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_result"></a> [result](#output\_result) | The result of the module. |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
