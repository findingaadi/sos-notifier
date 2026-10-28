# Who can use this role: the Lambda service
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "sos-handler-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Permission to write logs to CloudWatch (an AWS-managed policy)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permission to add items to our table, and nothing else
data "aws_iam_policy_document" "dynamodb_write" {
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.sos_requests.arn]
  }
}

resource "aws_iam_role_policy" "dynamodb_write" {
  name   = "dynamodb-write"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.dynamodb_write.json
}