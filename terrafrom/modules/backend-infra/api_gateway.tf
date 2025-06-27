# API Gateway for the Lambda function - Creates HTTP endpoints to trigger the Lambda
# Provides a RESTful interface for clients to interact with our serverless backend
resource "aws_api_gateway_rest_api" "api" {
  name        = "${local.api_handler_lambda_name}-api"
  description = "API Gateway for ${local.api_handler_lambda_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create a resource in the API Gateway - Defines the API endpoint path "/post-resource"
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "post-resource"
}

# Add post method to the resource - Configures POST HTTP method on the endpoint
# Enables clients to send data to the Lambda function
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE" // No authentication required to access the API
}

# Integration between API Gateway and Lambda - Connects the API endpoint to our Lambda
# Uses AWS_PROXY integration type to automatically handle request/response mapping
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.api_handler_lambda.invoke_arn
}

# lambda permission for API Gateway - Authorizes API Gateway to invoke the Lambda function
# Without this permission, API Gateway would receive an "unauthorized" error when calling the Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.api_handler_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  depends_on = [aws_api_gateway_integration.lambda_integration]
}


# Deployment for the API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    # aws_api_gateway_method_response.method_response,
    # aws_api_gateway_integration_response.integration_response
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "Deployment for ${local.api_handler_lambda_name} API"

  triggers = {
    redeployment = sha1(jsonencode({
      lambda_function = module.api_handler_lambda.arn
    })) # Forces redeployment when Lambda function changes
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage for the API Gateway - Defines a named stage for the API deployment
# Stages allow versioning and management of different API environments (e.g., dev, prod
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = var.env
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
