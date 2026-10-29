# Quick create: AWS builds the route, the Lambda connection and a
# $default stage that redeploys automatically
resource "aws_apigatewayv2_api" "sos" {
  name          = "sos-api"
  protocol_type = "HTTP"
  target        = aws_lambda_function.sos_handler.arn
  route_key     = "POST /sos"

  cors_configuration {
    # shortcut: any website may call the API, narrow it to the S3 site's address in Step 4
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["content-type"]
  }
}

# Lambda refuses to run for callers it hasn't approved, so approve this API
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sos_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.sos.execution_arn}/*/*"
}