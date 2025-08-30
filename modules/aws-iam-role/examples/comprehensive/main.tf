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

# Example showing all available features
module "comprehensive_iam_role" {
  source = "../../"

  name        = "comprehensive-example-role"
  description = "Comprehensive IAM role example showcasing all features"
  path        = "/application/"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:user/admin"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "comprehensive-example-12345"
          }
          DateGreaterThan = {
            "aws:CurrentTime" = "2024-01-01T00:00:00Z"
          }
        }
      }
    ]
  })

  max_session_duration  = 7200  # 2 hours
  force_detach_policies = true
  
  # Example permissions boundary (uncomment if you have one)
  # permissions_boundary = "arn:aws:iam::123456789012:policy/DeveloperBoundary"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policies = {
    s3_comprehensive_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "S3BucketAccess"
            Effect = "Allow"
            Action = [
              "s3:ListBucket",
              "s3:GetBucketLocation",
              "s3:GetBucketVersioning"
            ]
            Resource = [
              "arn:aws:s3:::comprehensive-example-bucket"
            ]
          },
          {
            Sid    = "S3ObjectAccess"
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:GetObjectVersion"
            ]
            Resource = [
              "arn:aws:s3:::comprehensive-example-bucket/*"
            ]
          }
        ]
      })
    }

    dynamodb_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "DynamoDBTableAccess"
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
          }
        ]
      })
    }

    secrets_manager_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
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
          }
        ]
      })
    }

    kms_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "KMSKeyAccess"
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
          }
        ]
      })
    }
  }

  create_instance_profile  = true
  instance_profile_name    = "comprehensive-example-instance-profile"
  instance_profile_path    = "/application/"

  tags = {
    Environment   = "production"
    Application   = "comprehensive-example"
    Owner         = "platform-team"
    CostCenter    = "engineering"
    Compliance    = "required"
    BackupSchedule = "daily"
  }
}
