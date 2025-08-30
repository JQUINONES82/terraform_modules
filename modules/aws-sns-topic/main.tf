/**
 * <!-- This will become the header in README.md
 *      Add a description of the module here.
 *      Do not include Variable or Output descriptions. -->
 * Comprehensive AWS SNS Topic module that supports all SNS features
 * including topic creation, subscriptions, access policies, encryption,
 * dead letter queues, and delivery status logging. Follows AWS best
 * practices for notification management and includes comprehensive
 * validation and security features.
 */

# Create the SNS topic
resource "aws_sns_topic" "this" {
  count = var.create_topic ? 1 : 0

  name                                     = var.name
  name_prefix                             = var.name_prefix
  display_name                            = var.display_name
  policy                                  = var.policy
  delivery_policy                         = var.delivery_policy
  application_success_feedback_role_arn   = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn   = var.application_failure_feedback_role_arn
  firehose_success_feedback_role_arn      = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate   = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn      = var.firehose_failure_feedback_role_arn
  http_success_feedback_role_arn          = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate       = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn          = var.http_failure_feedback_role_arn
  lambda_success_feedback_role_arn        = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate     = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn        = var.lambda_failure_feedback_role_arn
  sqs_success_feedback_role_arn           = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate        = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn           = var.sqs_failure_feedback_role_arn
  kms_master_key_id                       = var.kms_master_key_id
  content_based_deduplication             = var.content_based_deduplication
  archive_policy                          = var.archive_policy
  signature_version                       = var.signature_version
  tracing_config                          = var.tracing_config

  tags = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.name != null || var.name_prefix != null
      error_message = "Either name or name_prefix must be specified."
    }

    precondition {
      condition = var.fifo_topic == false || (
        var.fifo_topic == true && 
        (var.name != null ? can(regex("\\.fifo$", var.name)) : can(regex("\\.fifo$", var.name_prefix)))
      )
      error_message = "FIFO topic names must end with .fifo suffix."
    }
  }
}

# Create topic subscriptions
resource "aws_sns_topic_subscription" "this" {
  for_each = var.create_topic ? var.subscriptions : {}

  topic_arn                       = aws_sns_topic.this[0].arn
  protocol                        = each.value.protocol
  endpoint                        = each.value.endpoint
  endpoint_auto_confirms          = try(each.value.endpoint_auto_confirms, null)
  confirmation_timeout_in_minutes = try(each.value.confirmation_timeout_in_minutes, null)
  raw_message_delivery           = try(each.value.raw_message_delivery, null)
  filter_policy                  = try(each.value.filter_policy, null)
  filter_policy_scope            = try(each.value.filter_policy_scope, null)
  delivery_policy                = try(each.value.delivery_policy, null)
  redrive_policy                 = try(each.value.redrive_policy, null)
  replay_policy                  = try(each.value.replay_policy, null)
  subscription_role_arn          = try(each.value.subscription_role_arn, null)

  depends_on = [aws_sns_topic.this]
}

# Create topic policy if specified
resource "aws_sns_topic_policy" "this" {
  count = var.create_topic && var.create_topic_policy && var.topic_policy != null ? 1 : 0

  arn    = aws_sns_topic.this[0].arn
  policy = var.topic_policy

  depends_on = [aws_sns_topic.this]
}

# Data source for topic policy document
data "aws_iam_policy_document" "topic_policy" {
  count = var.create_topic && var.create_topic_policy && var.topic_policy == null ? 1 : 0

  statement {
    sid    = "DefaultTopicPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.topic_policy_principals
    }

    actions = var.topic_policy_actions

    resources = [aws_sns_topic.this[0].arn]

    dynamic "condition" {
      for_each = var.topic_policy_conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

# Apply generated topic policy
resource "aws_sns_topic_policy" "generated" {
  count = var.create_topic && var.create_topic_policy && var.topic_policy == null ? 1 : 0

  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.topic_policy[0].json

  depends_on = [aws_sns_topic.this]
}
