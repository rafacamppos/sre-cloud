provider "aws"{
    region = "us-east-1"
}

resource "aws_sqs_queue" "queue" {
  name                              = "sqs_principal"
  message_retention_seconds         = var.message_retention_seconds
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  fifo_queue                        = false
  content_based_deduplication       = false
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  max_message_size                  = var.max_message_size
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn,
    maxReceiveCount     = 3
  })
  tags = var.tags
}

data "aws_iam_policy_document" "queue" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.queue.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    principals {
      type        = "AWS"
      identifiers = var.allowed_arns == null ? [local.account_id] : var.allowed_arns
    }
  }
}


resource "aws_sqs_queue" "deadletter_queue" {
  name                              = "deadletter_queue"
  message_retention_seconds         = 86400
  visibility_timeout_seconds        = 90
  fifo_queue                        = false
  content_based_deduplication       = false
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  tags                              = {}
}

resource "aws_sqs_queue_policy" "deadletter_queue" {
  queue_url = aws_sqs_queue.deadletter_queue.id
  policy    = data.aws_iam_policy_document.deadletter_queue.json
}

data "aws_iam_policy_document" "deadletter_queue" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.deadletter_queue.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    principals {
      type        = "AWS"
      identifiers = var.allowed_arns == null ? [local.account_id] : var.allowed_arns
    }
  }
}
