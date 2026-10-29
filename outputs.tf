output "api_url" {
  value = "${aws_apigatewayv2_api.sos.api_endpoint}/sos"
}