output "file_upload_bucket_name" {
  description = "Name of the S3 bucket receiving raw markdown uploads."
  value       = aws_s3_bucket.file_upload.bucket
}

output "converted_file_storage_bucket_name" {
  description = "Name of the S3 bucket storing converted HTML files."
  value       = aws_s3_bucket.converted_file_storage.bucket
}

output "sentiments_table_name" {
  description = "Name of the DynamoDB table storing sentiment analysis results."
  value       = aws_dynamodb_table.sentiments_records.name
}

output "sentiments_queue_url" {
  description = "URL of the SQS queue feeding the sentiment analysis Lambda."
  value       = aws_sqs_queue.sentiments_queue.id
}

output "conversion_queue_url" {
  description = "URL of the SQS queue feeding the conversion service Lambda."
  value       = aws_sqs_queue.conversion_queue.id
}

output "lambda_function_names" {
  description = "Names of the deployed Lambda functions."
  value       = { for k, fn in aws_lambda_function.functions : k => fn.function_name }
}
