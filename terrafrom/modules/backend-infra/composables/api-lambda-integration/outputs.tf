
# OUTPUTS 

# Outputs for the Lambda integration details
output "lambda_integration" {
    description = "Integration details for the Lambda function"
    value = aws_api_gateway_integration.lambda_integration
}