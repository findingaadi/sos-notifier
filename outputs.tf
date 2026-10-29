output "api_url" {
  value = "${aws_apigatewayv2_api.sos.api_endpoint}/sos"
}
output "site_url" {
  value = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}