
# API Gateway for the Lambda function - Creates HTTP endpoints to trigger the Lambda
# Provides a RESTful interface for clients to interact with our serverless backend
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.namespace}-api-${var.env}"
  description = "API Gateway for ${var.namespace} "

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Deployment for the API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    module.upload_request_endpoint.lambda_integration,
    module.get_image_endpoint.lambda_integration,
    module.get_all_images_endpoint.lambda_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "Deployment for ${var.namespace} REST API"

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

module "upload_request_endpoint" {
  source = "./endpoints/upload-request/"
  api_root = aws_api_gateway_rest_api.api
  env = var.env
}

module "get_image_endpoint" {
  source = "./endpoints/get-image/"
  api_root = aws_api_gateway_rest_api.api
  env = var.env
}

module "get_all_images_endpoint" {
  source = "./endpoints/get-all-images/"
  api_root = aws_api_gateway_rest_api.api
  env = var.env
}


