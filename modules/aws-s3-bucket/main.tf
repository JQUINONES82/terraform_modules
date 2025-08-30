/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * L1 Module to create an S3 bucket.
  *
  */

resource "aws_s3_bucket" "this" {
  # checkov:skip=CKV2_AWS_61: N/A
  # checkov:skip=CKV2_AWS_62: N/A
  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.bucket != null && var.bucket_prefix != null)
      error_message = "bucket and bucket_prefix cannot both be set."
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "this" {
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_logging" "this" {
  count                 = var.logging_enabled ? 1 : 0
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  target_bucket         = var.logging_target_bucket
  target_prefix         = var.logging_target_prefix
  lifecycle {
    precondition {
      condition     = var.logging_target_bucket != null
      error_message = "If logging is enabled logging_target_bucket must be set."
    }
    precondition {
      condition     = var.logging_target_prefix != null
      error_message = "If logging is enabled logging_target_prefix must be set."
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count                 = var.enable_server_side_encryption ? 1 : 0
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.replication_role
  token  = var.replication_token
  rule {
    status = "Enabled"
    destination {
      bucket        = var.replication_target_bucket
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix                   = filter.value.prefix
          object_size_greater_than = filter.value.object_size_greater_than
          object_size_less_than    = filter.value.object_size_less_than

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          date                         = expiration.value.date
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          days          = transition.value.days
          date          = transition.value.date
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions != null ? rule.value.noncurrent_version_transitions : []
        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      id              = cors_rule.value.id
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.website_configuration.index_document != null ? [var.website_configuration.index_document] : []
    content {
      suffix = index_document.value.suffix
    }
  }

  dynamic "error_document" {
    for_each = var.website_configuration.error_document != null ? [var.website_configuration.error_document] : []
    content {
      key = error_document.value.key
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_configuration.redirect_all_requests_to != null ? [var.website_configuration.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }

  dynamic "routing_rule" {
    for_each = var.website_configuration.routing_rules != null ? var.website_configuration.routing_rules : []
    content {
      dynamic "condition" {
        for_each = routing_rule.value.condition != null ? [routing_rule.value.condition] : []
        content {
          http_error_code_returned_equals = condition.value.http_error_code_returned_equals
          key_prefix_equals               = condition.value.key_prefix_equals
        }
      }
      redirect {
        host_name               = routing_rule.value.redirect.host_name
        http_redirect_code      = routing_rule.value.redirect.http_redirect_code
        protocol                = routing_rule.value.redirect.protocol
        replace_key_prefix_with = routing_rule.value.redirect.replace_key_prefix_with
        replace_key_with        = routing_rule.value.redirect.replace_key_with
      }
    }
  }
}

resource "aws_s3_bucket_notification" "this" {
  count  = var.notification_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "topic" {
    for_each = var.notification_configuration.sns_topics != null ? var.notification_configuration.sns_topics : []
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.notification_configuration.sqs_queues != null ? var.notification_configuration.sqs_queues : []
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }

  dynamic "lambda_function" {
    for_each = var.notification_configuration.lambda_functions != null ? var.notification_configuration.lambda_functions : []
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }
}

resource "aws_s3_bucket_accelerate_configuration" "this" {
  count  = var.enable_transfer_acceleration ? 1 : 0
  bucket = aws_s3_bucket.this.id
  status = "Enabled"
}

resource "aws_s3_bucket_request_payment_configuration" "this" {
  count  = var.request_payer != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  payer  = var.request_payer
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = var.object_ownership != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = var.intelligent_tiering_configurations
  bucket   = aws_s3_bucket.this.id
  name     = each.value.name
  status   = each.value.status

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []
    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "tiering" {
    for_each = each.value.tiering
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}
