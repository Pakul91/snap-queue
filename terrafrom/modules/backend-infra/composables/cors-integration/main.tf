# OPTIONS HTTP method for CORS
resource "aws_api_gateway_method" "cors_options" {
  rest_api_id      = var.api_root.id
  resource_id      = var.resource_id
  http_method      = "OPTIONS"
  authorization    = "NONE"
}

# OPTIONS integration
resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id          = var.api_root.id
  resource_id          = var.resource_id
  http_method          = "OPTIONS"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }

  depends_on = [
    aws_api_gateway_method.cors_options
  ]
}

# OPTIONS integration response
resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = var.api_root.id
  resource_id = var.resource_id
  http_method = aws_api_gateway_integration.cors_integration.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# OPTIONS method response
resource "aws_api_gateway_method_response" "cors_method_response" {
  rest_api_id = var.api_root.id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}



