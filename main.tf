# ─── S3 buckets ───────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "file_upload" {
  bucket = "${local.name_prefix}-file-upload"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-file-upload"
  })
}

resource "aws_s3_bucket" "converted_file_storage" {
  bucket = "${local.name_prefix}-converted-file-storage"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-converted-file-storage"
  })
}

# ─── DynamoDB ────────────────────────────────────────────────────────────────

resource "aws_dynamodb_table" "sentiments_records" {
  name         = "${local.name_prefix}-${var.sentiments_table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileKey"

  attribute {
    name = "fileKey"
    type = "S"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${var.sentiments_table_name}"
  })
}

# ─── Fan-out: S3 -> SNS -> SQS (sentiments + conversion) ─────────────────────

resource "aws_sns_topic" "file_upload_notification" {
  name = "${local.name_prefix}-file-upload-notification"

  tags = local.common_tags
}

resource "aws_sns_topic_policy" "file_upload_notification" {
  arn = aws_sns_topic.file_upload_notification.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.file_upload_notification.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_s3_bucket.file_upload.arn }
      }
    }]
  })
}

resource "aws_s3_bucket_notification" "file_upload" {
  bucket = aws_s3_bucket.file_upload.id

  topic {
    topic_arn     = aws_sns_topic.file_upload_notification.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".md"
  }

  depends_on = [aws_sns_topic_policy.file_upload_notification]
}

resource "aws_sqs_queue" "sentiments_queue" {
  name = "${local.name_prefix}-sentiments-queue"

  tags = local.common_tags
}

resource "aws_sqs_queue" "conversion_queue" {
  name = "${local.name_prefix}-conversion-queue"

  tags = local.common_tags
}

resource "aws_sqs_queue_policy" "sentiments_queue" {
  queue_url = aws_sqs_queue.sentiments_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.sentiments_queue.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.file_upload_notification.arn }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "conversion_queue" {
  queue_url = aws_sqs_queue.conversion_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.conversion_queue.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.file_upload_notification.arn }
      }
    }]
  })
}

resource "aws_sns_topic_subscription" "sentiments_queue" {
  topic_arn            = aws_sns_topic.file_upload_notification.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.sentiments_queue.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "conversion_queue" {
  topic_arn            = aws_sns_topic.file_upload_notification.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.conversion_queue.arn
  raw_message_delivery = true
}

# ─── IAM role shared by both Lambda functions ────────────────────────────────

resource "aws_iam_role" "lambda_exec" {
  name = "${local.name_prefix}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name = "${local.name_prefix}-lambda-permissions"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = [
          aws_sqs_queue.sentiments_queue.arn,
          aws_sqs_queue.conversion_queue.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.file_upload.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.converted_file_storage.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["comprehend:DetectSentiment"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.sentiments_records.arn
      },
    ]
  })
}

# ─── Lambda packages (one per function) ──────────────────────────────────────

resource "null_resource" "lambda_packages" {
  for_each = local.lambda_functions

  triggers = {
    handler_sha = filesha256("${path.module}/src/lambda/${each.key}/handler.py")
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/build_lambda_package.sh ${path.module} ${each.key}"
  }
}

data "archive_file" "lambda_zips" {
  for_each = local.lambda_functions

  type        = "zip"
  source_dir  = "${path.module}/.build/${each.key}"
  output_path = "${path.module}/.build/zips/${each.key}.zip"

  depends_on = [null_resource.lambda_packages]
}

# ─── Lambda functions ─────────────────────────────────────────────────────────

resource "aws_lambda_function" "functions" {
  for_each = local.lambda_functions

  function_name = "${local.name_prefix}-${replace(each.key, "_", "-")}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  filename         = data.archive_file.lambda_zips[each.key].output_path
  source_code_hash = data.archive_file.lambda_zips[each.key].output_base64sha256

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.sentiments_records.name
      DEST_BUCKET = aws_s3_bucket.converted_file_storage.bucket
      REGION      = var.aws_region
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${replace(each.key, "_", "-")}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy.lambda_permissions,
  ]
}

resource "aws_lambda_event_source_mapping" "sentiments" {
  event_source_arn = aws_sqs_queue.sentiments_queue.arn
  function_name    = aws_lambda_function.functions["sentiment_analysis"].arn
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "conversion" {
  event_source_arn = aws_sqs_queue.conversion_queue.arn
  function_name    = aws_lambda_function.functions["conversion_service"].arn
  batch_size       = 1
}
