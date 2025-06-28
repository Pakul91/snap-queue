/**
  * Terraform module for integrating AWS API Gateway with Lambda functions
  * This module sets up the necessary API Gateway integration and permissions for Lambda invocation.
*/



# Integration between API Gateway and Lambda - Connects the API endpoint to our Lambda
# Uses AWS_PROXY integration type to automatically handle request/response mapping
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = var.rest_api.id
  resource_id             = var.resource_id
  http_method             = var.http_method
  integration_http_method = var.integration_http_method
  type                    = var.type
  uri                     = var.uri
}

# lambda permission for API Gateway - Authorizes API Gateway to invoke the Lambda function
# Without this permission, API Gateway would receive an "unauthorized" error when calling the Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.rest_api.execution_arn}/*/*/${var.endpoint_path}"

  depends_on = [aws_api_gateway_integration.lambda_integration]
}


# OUTPUTS 

# Outputs for the Lambda integration details
output "lambda_integration" {
    description = "Integration details for the Lambda function"
    value = aws_api_gateway_integration.lambda_integration
}