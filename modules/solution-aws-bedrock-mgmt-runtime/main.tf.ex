resource "aws_bedrock_model_invocation_logging_configuration" "logging" {
  cloudwatch_config {
    log_group_name = "/aws/bedrock/invocations"
    role_arn       = aws_iam_role.bedrock_logging.arn
  }
  s3_config {
    bucket_name = aws_s3_bucket.bedrock_logs.bucket
    role_arn    = aws_iam_role.bedrock_logging.arn
    prefix      = "invocations/"
  }
  text_data_delivery_enabled  = true
  image_data_delivery_enabled = true
  embedding_data_delivery_enabled = true
}

# CloudWatch Logs group (with retention)
resource "aws_cloudwatch_log_group" "bedrock_invocations" {
  name              = "/aws/bedrock/invocations"
  retention_in_days = 90
}

# S3 bucket for durable logs (MFA delete & versioning recommended in prod)
resource "aws_s3_bucket" "bedrock_logs" {
  bucket = "org-sec-bucket-bedrock-logs"
}

resource "aws_s3_bucket_versioning" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.logs_kms.arn
    }
  }
}

# S3 bucket hardening
resource "aws_s3_bucket_public_access_block" "bedrock_logs" {
  bucket                  = aws_s3_bucket.bedrock_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Require TLS
      {
        Sid: "DenyInsecureTransport",
        Effect: "Deny",
        Principal: "*",
        Action: "s3:*",
        Resource: [
          aws_s3_bucket.bedrock_logs.arn,
          "${aws_s3_bucket.bedrock_logs.arn}/*"
        ],
        Condition: { Bool: { "aws:SecureTransport": "false" } }
      },
      # Deny unencrypted PUTs (defense in depth vs. bucket SSE)
      {
        Sid: "DenyUnEncryptedObjectUploads",
        Effect: "Deny",
        Principal: "*",
        Action: "s3:PutObject",
        Resource: "${aws_s3_bucket.bedrock_logs.arn}/*",
        Condition: {
          StringNotEquals: {
            "s3:x-amz-server-side-encryption": "aws:kms"
          }
        }
      }
    ]
  })
}

# KMS CMK for logs
resource "aws_kms_key" "logs_kms" {
  description         = "KMS key for Bedrock logs"
  enable_key_rotation = true
}

# IAM role Bedrock uses to deliver logs
data "aws_iam_policy_document" "bedrock_logging_assume" {
  statement {
    effect = "Allow"
    principals { type = "Service", identifiers = ["bedrock.amazonaws.com"] }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bedrock_logging" {
  name               = "bedrock-logging-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_logging_assume.json
}

data "aws_iam_policy_document" "bedrock_logging" {
  statement {
    sid     = "WriteCloudWatch"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
    resources = [
      "${aws_cloudwatch_log_group.bedrock_invocations.arn}:*",
      aws_cloudwatch_log_group.bedrock_invocations.arn
    ]
  }
  statement {
    sid     = "WriteS3"
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:AbortMultipartUpload", "s3:ListBucketMultipartUploads"]
    resources = [
      aws_s3_bucket.bedrock_logs.arn,
      "${aws_s3_bucket.bedrock_logs.arn}/*"
    ]
  }
  statement {
    sid     = "UseKMS"
    effect  = "Allow"
    actions = ["kms:Encrypt", "kms:GenerateDataKey"]
    resources = [aws_kms_key.logs_kms.arn]
  }
}

resource "aws_iam_role_policy" "bedrock_logging" {
  role   = aws_iam_role.bedrock_logging.id
  policy = data.aws_iam_policy_document.bedrock_logging.json
}

# Bedrock invocation logging configuration
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  cloudwatch_config {
    log_group_name = aws_cloudwatch_log_group.bedrock_invocations.name
    role_arn       = aws_iam_role.bedrock_logging.arn
  }
  s3_config {
    bucket_name = aws_s3_bucket.bedrock_logs.bucket
    prefix      = "invocations/"
    role_arn    = aws_iam_role.bedrock_logging.arn
  }

  text_data_delivery_enabled       = true
  image_data_delivery_enabled      = true
  embedding_data_delivery_enabled  = true
}


# Security group for interface endpoints
resource "aws_security_group" "vpce_bedrock" {
  name        = "sg-vpce-bedrock"
  description = "Allow HTTPS from VPC to Bedrock endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # or your app subnets’ CIDRs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPC endpoints for Bedrock control plane & runtime
resource "aws_vpc_endpoint" "bedrock" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.bedrock"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce_bedrock.id]
  private_dns_enabled = true

  # Endpoint policy to restrict principals and regions (defense in depth)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect: "Allow"
      Principal: {"AWS": var.allowed_principals_arns}
      Action: "bedrock:*"
      Resource: "*"
      Condition: {
        StringEquals: { "aws:RequestedRegion": var.region }
      }
    }]
  })
}

resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce_bedrock.id]
  private_dns_enabled = true
  # (Optional) similar endpoint policy restricting InvokeModel to certain roles
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect: "Allow"
      Principal: {"AWS": var.allowed_principals_arns}
      Action: [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ApplyGuardrail"
      ]
      Resource: "*"
    }]
  })
}


# Execution role for an app/compute that talks to Bedrock
data "aws_iam_policy_document" "app_assume" {
  statement {
    effect = "Allow"
    principals { type = "Service", identifiers = ["ecs-tasks.amazonaws.com"] } # or lambda.amazonaws.com, ec2.amazonaws.com
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bedrock_app" {
  name               = "bedrock-app-role"
  assume_role_policy = data.aws_iam_policy_document.app_assume.json
}

# Restrict to explicit model ARNs you’ve enabled (example: Claude 3.5 Sonnet)
locals {
  allowed_model_arns = [
    "arn:aws:bedrock:${var.region}::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0"
  ]
}

data "aws_iam_policy_document" "bedrock_invoke" {
  statement {
    sid     = "InvokeAllowedModelsOnly"
    effect  = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = local.allowed_model_arns
  }
  statement {
    sid     = "ApplyGuardrailsIfUsed"
    effect  = "Allow"
    actions = ["bedrock:ApplyGuardrail"]
    resources = ["*"] # or specific guardrail ARNs
  }
}

resource "aws_iam_role_policy" "bedrock_invoke" {
  role   = aws_iam_role.bedrock_app.id
  policy = data.aws_iam_policy_document.bedrock_invoke.json
}

resource "aws_bedrock_guardrail" "sensitive_use" {
  name        = "sensitive-use"
  description = "Enterprise content safety baseline"
  blocked_input_mime_types  = ["text/plain","application/json"]
  blocked_output_mime_types = ["text/plain","application/json"]

  content_policy_config {
    # simple example: block PII
    pii_entities_config {
      action = "BLOCK"
      type   = "ALL"
    }
  }

  # Tie this guardrail at call time using 'ApplyGuardrail' (see IAM above)
}

