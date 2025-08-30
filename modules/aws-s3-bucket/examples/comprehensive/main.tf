# tflint-ignore: all

module "comprehensive_s3_bucket" {
  source = "../../"

  bucket                        = "my-comprehensive-s3-bucket-${random_id.bucket_suffix.hex}"
  force_destroy                 = true
  object_lock_enabled          = true
  tags = {
    Environment = "development"
    Project     = "example"
    Owner       = "terraform"
  }

  # Public access blocking
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Versioning
  versioning_enabled = true

  # Server-side encryption
  enable_server_side_encryption = true
  kms_master_key_id             = aws_kms_key.s3_key.arn

  # Lifecycle configuration
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
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = 2555  # 7 years
      }
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    },
    {
      id     = "delete_incomplete_multipart_uploads"
      status = "Enabled"
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]

  # CORS configuration
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://example.com", "https://www.example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  # Website configuration
  website_configuration = {
    index_document = {
      suffix = "index.html"
    }
    error_document = {
      key = "error.html"
    }
    routing_rules = [
      {
        condition = {
          key_prefix_equals = "docs/"
        }
        redirect = {
          replace_key_prefix_with = "documents/"
        }
      }
    ]
  }

  # Notification configuration
  notification_configuration = {
    sns_topics = [
      {
        topic_arn     = aws_sns_topic.s3_notifications.arn
        events        = ["s3:ObjectCreated:*"]
        filter_prefix = "uploads/"
        filter_suffix = ".jpg"
      }
    ]
    lambda_functions = [
      {
        lambda_function_arn = aws_lambda_function.s3_processor.arn
        events              = ["s3:ObjectCreated:Put"]
        filter_prefix       = "process/"
      }
    ]
  }

  # Transfer acceleration
  enable_transfer_acceleration = true

  # Request payer
  request_payer = "BucketOwner"

  # Object ownership
  object_ownership = "BucketOwnerEnforced"

  # Intelligent tiering
  intelligent_tiering_configurations = {
    EntireBucket = {
      name   = "EntireBucket"
      status = "Enabled"
      tiering = [
        {
          access_tier = "ARCHIVE_ACCESS"
          days        = 90
        },
        {
          access_tier = "DEEP_ARCHIVE_ACCESS"
          days        = 180
        }
      ]
    }
  }

  # Logging
  logging_enabled       = true
  logging_target_bucket = aws_s3_bucket.access_logs.id
  logging_target_prefix = "access-logs/"
}

# KMS key for S3 encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-bucket-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

# Access logs bucket
resource "aws_s3_bucket" "access_logs" {
  bucket        = "my-s3-access-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SNS topic for notifications
resource "aws_sns_topic" "s3_notifications" {
  name = "s3-bucket-notifications"
}

# Lambda function for processing
resource "aws_lambda_function" "s3_processor" {
  filename         = "lambda.zip"
  function_name    = "s3-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Create a dummy lambda zip file
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda.zip"
  source {
    content  = "def handler(event, context): return 'Hello from Lambda!'"
    filename = "index.py"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "s3-processor-lambda-role"

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
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda permission for S3
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.comprehensive_s3_bucket.arn
}

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.comprehensive_s3_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.comprehensive_s3_bucket.arn
}

output "website_endpoint" {
  description = "The website endpoint"
  value       = module.comprehensive_s3_bucket.website_endpoint
}
