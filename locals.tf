locals {
  name_prefix = var.project_name

  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Demo      = "Serverless File Conversion"
  }

  lambda_functions = {
    sentiment_analysis = { queue = "sentiments" }
    conversion_service = { queue = "conversion" }
  }
}
