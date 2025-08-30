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

# Using aws_iam_policy_document data source for better policy management
data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "S3ReadWriteAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      "arn:aws:s3:::example-data-bucket/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-metadata-directive"
      values   = ["COPY", "REPLACE"]
    }
  }

  statement {
    sid    = "S3BucketListAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::example-data-bucket"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["data/*", "temp/*"]
    }
  }

  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::example-data-bucket",
      "arn:aws:s3:::example-data-bucket/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_access" {
  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/data-processing-*"
    ]
  }

  statement {
    sid    = "CloudWatchMetricsAccess"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["DataProcessing/Application"]
    }
  }
}

# Combine multiple policy documents
data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    data.aws_iam_policy_document.s3_access.json,
    data.aws_iam_policy_document.cloudwatch_access.json
  ]
}

module "data_source_policy" {
  source = "../../"

  name        = "data-source-generated-policy"
  description = "IAM policy generated using aws_iam_policy_document data source"

  policy = data.aws_iam_policy_document.combined.json

  tags = {
    Environment = "dev"
    Purpose     = "data-source-example"
    Generated   = "terraform-data-source"
  }
}
