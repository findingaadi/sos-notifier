resource "aws_iam_user" "listener" {
  name = "sos-listener"
}

data "aws_iam_policy_document" "dynamodb_read" {
  statement {
    actions   = ["dynamodb:Scan"]
    resources = [aws_dynamodb_table.sos_requests.arn]
  }
}

resource "aws_iam_user_policy" "listener" {
  name   = "dynamodb-read"
  user   = aws_iam_user.listener.name
  policy = data.aws_iam_policy_document.dynamodb_read.json
}

resource "aws_iam_access_key" "listener" {
  user = aws_iam_user.listener.name
}