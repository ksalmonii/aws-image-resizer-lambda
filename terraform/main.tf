resource "aws_dynamodb_table" "image_resizer_database" {
  name           = "image-resizer-database"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}



provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "origin_bucket" {
  bucket = var.origin_bucket_name
}

resource "aws_s3_bucket" "resized_bucket" {
  bucket = var.resized_bucket_name
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.frontend_bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_dynamodb_table" "metadata_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "image_id"

  attribute {
    name = "image_id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "ImageResizerDatabase-role-sslvzfr5"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_lambda_function" "ImageResizerDatabase" {
  function_name = "ImageResizerDatabase"
  role          = "arn:aws:iam::637423305058:role/service-role/ImageResizerDatabase-role-s5vzfr5e"
  handler       = "LambdaImageDB.Lambda_handler"
  runtime       = "python3.9"
  filename      = "image-resizer.zip"

  environment {
    variables = {
      DEST_BUCKET = var.resized_bucket_name
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }
}

resource "aws_s3_bucket_notification" "frontend_bucket_notification" {
  bucket = aws_s3_bucket.frontend_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ImageResizerDatabase.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ImageResizerDatabase.function_name

  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.origin_bucket.arn
}
