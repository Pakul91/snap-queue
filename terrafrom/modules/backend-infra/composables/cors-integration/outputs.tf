
output "cors_integration" {
  description = "Integration details for the CORS OPTIONS method"
  value = aws_api_gateway_integration.cors_integration
}
