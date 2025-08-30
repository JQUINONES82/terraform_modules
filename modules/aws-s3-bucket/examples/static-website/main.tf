# tflint-ignore: all

module "static_website_bucket" {
  source = "../../"

  bucket        = "my-static-website-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Environment = "production"
    Project     = "static-website"
    Purpose     = "website-hosting"
  }

  # Public access for website hosting
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
    routing_rules = [
      {
        condition = {
          http_error_code_returned_equals = "404"
        }
        redirect = {
          replace_key_with = "error.html"
        }
      }
    ]
  }

  # CORS for web assets
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      max_age_seconds = 86400
    }
  ]

  # Object ownership for public access
  object_ownership = "BucketOwnerPreferred"

  # Bucket policy for public read access
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::my-static-website-${random_id.bucket_suffix.hex}/*"
      }
    ]
  })
}

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Upload sample files
resource "aws_s3_object" "index" {
  bucket       = module.static_website_bucket.id
  key          = "index.html"
  content      = "<html><body><h1>Welcome to my static website!</h1></body></html>"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = module.static_website_bucket.id
  key          = "error.html"
  content      = "<html><body><h1>404 - Page Not Found</h1></body></html>"
  content_type = "text/html"
}

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = module.static_website_bucket.website_endpoint
}

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.static_website_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.static_website_bucket.arn
}
