
variable "aws_region" {
  default = "us-east-1"
}

variable "origin_bucket_name" {
  default = "bucketresizerkeith"
}

variable "resized_bucket_name" {
  default = "image-resizer-origin"
}

variable "frontend_bucket_name" {
  default = "image-resizer-frontend"
}

variable "dynamodb_table_name" {
  default = "image-resizer-database"
}

variable "lambda_zip_path" {
  default = "../lambda/image_resizer.zip"
}
