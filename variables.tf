variable "project_name" {
  description = "Project name used as prefix for all resources."
  type        = string
  default     = "floci-file-conversion"
}

variable "aws_region" {
  description = "AWS region (simulated by floci)."
  type        = string
  default     = "us-east-1"
}

variable "sentiments_table_name" {
  description = "Name of the DynamoDB table storing sentiment analysis results."
  type        = string
  default     = "sentiments-records"
}
