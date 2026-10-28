# Zips the lambda/ folder on your machine
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/lambda.zip"
}

# Create the log group ourselves so we control how long logs are kept
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/sos-handler"
  retention_in_days = 14
}

resource "aws_lambda_function" "sos_handler" {
  function_name    = "sos-handler"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.13"
  handler          = "handler.handler" # file name . function name
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.sos_requests.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_logs,
  ]
}