# Advanced: Terraform configuration for serverless infrastructure
# This is for reference only - not part of the main lab

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# DynamoDB Table
resource "aws_dynamodb_table" "tasks" {
  name           = "${var.username}-tasks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  tags = {
    Name = "${var.username}-tasks"
    Lab  = "11"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.username}-lambda-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

# Variables
variable "username" {
  description = "Username prefix for resources"
  type        = string
  default     = "user1"  # Replace with your username
}

# Outputs
output "dynamodb_table_name" {
  value = aws_dynamodb_table.tasks.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
