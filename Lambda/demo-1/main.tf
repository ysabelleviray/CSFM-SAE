#Lambda with IAM and python

provider "aws" {
  region = "us-east-1"
}

# Create IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Define Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda"
  runtime = "python3.8"
  handler = "lambda_python.lambda_handler"
  filename = "lambda_python.zip"  
  role = aws_iam_role.lambda_execution_role.arn
  memory_size = 128
  timeout     = 10
}


# Output the Lambda Function ARN
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.example_lambda.arn
}

# Output the IAM Role ARN
output "lambda_execution_role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

# Output the Lambda Function Name
output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.example_lambda.function_name
}