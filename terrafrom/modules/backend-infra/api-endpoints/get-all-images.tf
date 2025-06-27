locals {
    get_all_images_endpoint = "get-image"
    get_all_images_http_method = "GET" 
    get_all_images_function_name = "get-all-images-handler-${var.env}"
    get_all_images_function_folder = "get-all-images"
}


# Create resources for each API endpoint - Defines the API endpoint paths
# These are the paths that clients will use to interact with the Lambda functions
resource "aws_api_gateway_resource" "get_all_images_endpoint" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = local.get_all_images_endpoint 
}

# Add GET method to the resource - Configures GET HTTP method on the endpoint
# Enables clients to retrieve images from the Lambda function
resource "aws_api_gateway_method" "get_all_images_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.get_all_images_endpoint.id
  http_method   = local.get_all_images_http_method 
  authorization = "NONE" // No authentication required to access the API
} 

# Lambda function for handling image retrieval requests
# This function processes GET requests to retrieve image data from storage
module "get_all_images_lambda" {
    source = "./composables/lambda/"
    lambda_function_name = local.get_all_images_function_name
    lambda_folder_name = local.get_all_images_function_folder
    env = var.env

    env_variables = {
        ENVIRONMENT = var.env    
        LOG_LEVEL   = "info"    
    }

    tags = {
        Environment = var.env
        Application = var.namespace  
    }
}

# Integration between API Gateway and Lambda
# Links the API endpoint to the Lambda function that will process the requests
module "get_all_images_lambda_integration" {
    source = "./composables/api-lambda-integration/"
    rest_api = aws_api_gateway_rest_api.api
    resource_id = aws_api_gateway_resource.get_all_images_path_param.id
    http_method = aws_api_gateway_method.get_all_images_method.http_method
    integration_http_method = "POST"  
    uri = module.get_all_images_lambda.invoke_arn  
    lambda_function_name = module.get_all_images_lambda.function_name  
}

  