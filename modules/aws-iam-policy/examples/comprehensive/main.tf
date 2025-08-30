terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Comprehensive IAM policy example showcasing all features
module "comprehensive_iam_policy" {
  source = "../../"

  name        = "comprehensive-policy-example"
  description = "Comprehensive IAM policy demonstrating all features including multiple services and conditions"
  path        = "/application/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3FullAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::comprehensive-example-bucket/*"
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
          IpAddress = {
            "aws:SourceIp" = [
              "203.0.113.0/24",
              "198.51.100.0/24"
            ]
          }
        }
      },
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucketVersions"
        ]
        Resource = [
          "arn:aws:s3:::comprehensive-example-bucket"
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/comprehensive-example-table",
          "arn:aws:dynamodb:*:*:table/comprehensive-example-table/index/*"
        ]
        Condition = {
          "ForAllValues:StringEquals" = {
            "dynamodb:Attributes" = [
              "id",
              "name",
              "email",
              "created_at"
            ]
          }
        }
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:comprehensive-example/*"
        ]
        Condition = {
          DateGreaterThan = {
            "aws:CurrentTime" = "2024-01-01T00:00:00Z"
          }
        }
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [
          "arn:aws:kms:*:*:key/12345678-1234-1234-1234-123456789012"
        ]
      },
      {
        Sid    = "CloudWatchAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "cloudwatch:namespace" = "Application/*"
          }
        }
      },
      {
        Sid    = "SNSPublish"
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          "arn:aws:sns:*:*:comprehensive-example-*"
        ]
      }
    ]
  })

  tags = {
    Environment     = "production"
    Application     = "comprehensive-example"
    Owner          = "platform-team"
    CostCenter     = "engineering"
    Compliance     = "required"
    SecurityReview = "approved"
    DataClass      = "confidential"
  }
}

# Example with policy versions
module "versioned_policy" {
  source = "../../"

  name        = "versioned-policy-example"
  description = "Policy demonstrating version management"

  # Initial policy version
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InitialVersion"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::example-bucket/*"
        ]
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
            Sid    = "VersionTwo"
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = [
              "arn:aws:s3:::example-bucket/*"
            ]
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
            Sid    = "VersionThree"
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject"
            ]
            Resource = [
              "arn:aws:s3:::example-bucket/*"
            ]
          },
          {
            Sid    = "S3ListAccess"
            Effect = "Allow"
            Action = [
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::example-bucket"
            ]
          }
        ]
      })
      set_as_default = true
    }
  }

  tags = {
    Environment = "dev"
    Purpose     = "version-management-example"
  }
}
