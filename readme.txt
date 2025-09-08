# AWS Image Resizer Lambda

This project is a serverless image processing pipeline built on AWS. It automatically resizes uploaded images using AWS Lambda and stores both the original and resized image URLs in DynamoDB. The frontend uploads images via API Gateway, and the backend handles resizing and metadata storage.

## 🛠️ Technologies Used
- AWS Lambda (Python)
- Amazon S3 (Origin and Destination buckets)
- API Gateway (HTTP API)
- DynamoDB (Metadata storage)
- Terraform (Infrastructure as Code)

## 📦 Features
- Upload images via frontend form
- Resize images using Pillow in Lambda
- Save resized images to a destination S3 bucket
- Store metadata (original/resized URLs) in DynamoDB
- CORS-enabled API Gateway integration
- Fully automated deployment with Terraform

## 🚀 How to Deploy
1. Clone the repo
2. Run `terraform init`
3. Run `terraform apply`
4. Upload an image via the frontend or Postman
5. Check DynamoDB for metadata and S3 for resized image

## 📁 Folder Structure
