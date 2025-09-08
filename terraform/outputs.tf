
output "origin_bucket_name" {
  value = aws_s3_bucket.origin_bucket.bucket
}

output "resized_bucket_name" {
  value = aws_s3_bucket.resized_bucket.bucket
}

output "frontend_bucket_url" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.metadata_table.name
}

output "lambda_function_name" {
  value = aws_lambda_function.ImageResizerDatabase.function_name
}
