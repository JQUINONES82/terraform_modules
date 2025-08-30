# tflint-ignore: all

# Example demonstrating various S3 bucket policy scenarios

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Example 1: Public Read-Only Bucket (e.g., for static websites)
module "public_read_bucket" {
  source = "../../"

  bucket        = "public-read-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true

  # Disable public access blocking for public read access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # Set object ownership to bucket owner preferred for public access
  object_ownership = "BucketOwnerPreferred"

  # Public read policy
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::public-read-bucket-${random_id.bucket_suffix.hex}/*"
      }
    ]
  })

  tags = {
    Example     = "public-read-policy"
    Environment = "demo"
  }
}

# Example 2: Restricted Access Bucket (only specific IAM role can access)
module "restricted_access_bucket" {
  source = "../../"

  bucket        = "restricted-access-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true

  # Keep public access blocked for security
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Policy allowing only specific IAM role
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.app_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::restricted-access-bucket-${random_id.bucket_suffix.hex}",
          "arn:aws:s3:::restricted-access-bucket-${random_id.bucket_suffix.hex}/*"
        ]
      }
    ]
  })

  tags = {
    Example     = "restricted-access-policy"
    Environment = "demo"
  }
}

# Example 3: CloudFront Origin Access Control (OAC) Bucket
module "cloudfront_oac_bucket" {
  source = "../../"

  bucket        = "cloudfront-oac-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true

  # Keep public access blocked - CloudFront will access via OAC
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # CloudFront OAC policy
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
        Resource = "arn:aws:s3:::cloudfront-oac-bucket-${random_id.bucket_suffix.hex}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.example.arn
          }
        }
      }
    ]
  })

  tags = {
    Example     = "cloudfront-oac-policy"
    Environment = "demo"
  }
}

# Example 4: Cross-Account Access Bucket
module "cross_account_bucket" {
  source = "../../"

  bucket        = "cross-account-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true

  # Policy allowing specific external AWS account
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::cross-account-bucket-${random_id.bucket_suffix.hex}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      }
    ]
  })

  tags = {
    Example     = "cross-account-policy"
    Environment = "demo"
  }
}

# Example 5: Conditional Access Bucket (IP restrictions and MFA)
module "conditional_access_bucket" {
  source = "../../"

  bucket        = "conditional-access-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true

  # Policy with IP restrictions and MFA requirements
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFromSpecificIPWithMFA"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::conditional-access-bucket-${random_id.bucket_suffix.hex}",
          "arn:aws:s3:::conditional-access-bucket-${random_id.bucket_suffix.hex}/*"
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ip_ranges
          }
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      },
      {
        Sid    = "DenyDeleteWithoutMFA"
        Effect = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteBucket"
        ]
        Resource = [
          "arn:aws:s3:::conditional-access-bucket-${random_id.bucket_suffix.hex}",
          "arn:aws:s3:::conditional-access-bucket-${random_id.bucket_suffix.hex}/*"
        ]
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  tags = {
    Example     = "conditional-access-policy"
    Environment = "demo"
  }
}

# Supporting resources for the examples

# IAM role for restricted access example
resource "aws_iam_role" "app_role" {
  name = "s3-app-role-${random_id.bucket_suffix.hex}"

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

  tags = {
    Example = "bucket-policy-demo"
  }
}

# CloudFront distribution for OAC example
resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example-oac-${random_id.bucket_suffix.hex}"
  description                       = "Example OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "example" {
  origin {
    domain_name              = module.cloudfront_oac_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
    origin_id                = "S3-${module.cloudfront_oac_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${module.cloudfront_oac_bucket.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Example = "bucket-policy-demo"
  }
}

# Variables for customization
variable "trusted_account_id" {
  description = "AWS Account ID to grant cross-account access"
  type        = string
  default     = "123456789012" # Replace with actual account ID
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the conditional bucket"
  type        = list(string)
  default     = ["203.0.113.0/24", "198.51.100.0/24"] # Example IP ranges
}

# Outputs
output "public_read_bucket" {
  description = "Public read bucket details"
  value = {
    id                 = module.public_read_bucket.id
    arn                = module.public_read_bucket.arn
    bucket_domain_name = module.public_read_bucket.bucket_domain_name
  }
}

output "restricted_access_bucket" {
  description = "Restricted access bucket details"
  value = {
    id  = module.restricted_access_bucket.id
    arn = module.restricted_access_bucket.arn
  }
}

output "cloudfront_oac_bucket" {
  description = "CloudFront OAC bucket details"
  value = {
    id                     = module.cloudfront_oac_bucket.id
    arn                    = module.cloudfront_oac_bucket.arn
    cloudfront_domain_name = aws_cloudfront_distribution.example.domain_name
  }
}

output "cross_account_bucket" {
  description = "Cross-account bucket details"
  value = {
    id  = module.cross_account_bucket.id
    arn = module.cross_account_bucket.arn
  }
}

output "conditional_access_bucket" {
  description = "Conditional access bucket details"
  value = {
    id  = module.conditional_access_bucket.id
    arn = module.conditional_access_bucket.arn
  }
}
