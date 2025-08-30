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

module "lambda_execution_role" {
  source = "../../"

  name = "lambda-execution-example-role"
  
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

  description = "Lambda execution role with S3 access"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
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
              "s3:PutObject",
              "s3:DeleteObject"
            ]
            Resource = [
              "arn:aws:s3:::example-lambda-bucket/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::example-lambda-bucket"
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
            Effect = "Allow"
            Action = [
              "dynamodb:GetItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem",
              "dynamodb:DeleteItem",
              "dynamodb:Query",
              "dynamodb:Scan"
            ]
            Resource = [
              "arn:aws:dynamodb:*:*:table/example-table",
              "arn:aws:dynamodb:*:*:table/example-table/index/*"
            ]
          }
        ]
      })
    }
  }

  max_session_duration = 3600  # 1 hour

  tags = {
    Environment = "prod"
    Service     = "lambda"
    Example     = "lambda-execution"
  }
}
