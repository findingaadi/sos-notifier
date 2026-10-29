output "api_url" {
  value = "${aws_apigatewayv2_api.sos.api_endpoint}/sos"
}
output "site_url" {
  value = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}

output "listener_access_key_id" {
  value = aws_iam_access_key.listener.id
}

output "listener_secret_access_key" {
  value     = aws_iam_access_key.listener.secret
  sensitive = true
}
