variable api_root {
  description = "Root resource of the API Gateway"
  type = object({
    id   = string
    root_resource_id = string
    execution_arn = string
  })
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

locals {
    get_image_endpoint = "get-image"
    get_image_http_method = "GET" 
    get_image_path_param = "image_id" 
    get_image_function_name = "get-image-handler-${var.env}"
    get_image_function_folder = "get-image"
}


# Create resources for each API endpoint - Defines the API endpoint paths
# These are the paths that clients will use to interact with the Lambda functions
resource "aws_api_gateway_resource" "get_image_endpoint" {
  rest_api_id = var.api_root.id
  parent_id   = var.api_root.root_resource_id
  path_part   = local.get_image_endpoint 
}

resource "aws_api_gateway_resource" "get_image_path_param" {
  rest_api_id = var.api_root.id
  parent_id   = aws_api_gateway_resource.get_image_endpoint.id
  path_part   = "{${local.get_image_path_param}}"
}

# Add GET method to the resource - Configures GET HTTP method on the endpoint
# Enables clients to retrieve images from the Lambda function
resource "aws_api_gateway_method" "get_image_method" {
  rest_api_id   = var.api_root.id
  resource_id   = aws_api_gateway_resource.get_image_path_param.id
  http_method   = local.get_image_http_method 
  authorization = "NONE" // No authentication required to access the API
} 

# Lambda function for handling image retrieval requests
# This function processes GET requests to retrieve image data from storage
module "get_image_lambda" {
    source = "../../composables/lambda/"
    lambda_function_name = local.get_image_function_name
    lambda_folder_name = local.get_image_function_folder
    env = var.env

    env_variables = {
        ENVIRONMENT = var.env    
        LOG_LEVEL   = "info"    
    }

    tags = {
        Environment = var.env
    }
}

# Integration between API Gateway and Lambda
# Links the API endpoint to the Lambda function that will process the requests
module "get_image_lambda_integration" {
    source = "../../composables/api-lambda-integration/"
    rest_api = var.api_root
    resource_id = aws_api_gateway_resource.get_image_path_param.id
    http_method = aws_api_gateway_method.get_image_method.http_method
    integration_http_method = "POST"  
    uri = module.get_image_lambda.invoke_arn 
    lambda_function_name = module.get_image_lambda.function_name
    endpoint_path = "${local.get_image_endpoint}/{${local.get_image_path_param}}"
}

output "lambda_integration" {
  description = "Integration details for the get image Lambda function"
  value = module.get_image_lambda_integration.lambda_integration
}
  