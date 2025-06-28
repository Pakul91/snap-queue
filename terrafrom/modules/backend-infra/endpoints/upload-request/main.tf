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
    upload_request_endpoint = "get-image"
    upload_request_http_method = "POST" 
    upload_request_function_name = "upload-request-handler-${var.env}"
    upload_request_function_folder = "upload-request"
}


# Create resources for each API endpoint - Defines the API endpoint paths
# These are the paths that clients will use to interact with the Lambda functions
resource "aws_api_gateway_resource" "upload_request_endpoint" {
  rest_api_id = var.api_root.id
  parent_id   = var.api_root.root_resource_id
  path_part   = local.upload_request_endpoint 
}

# Add GET method to the resource - Configures GET HTTP method on the endpoint
# Enables clients to retrieve images from the Lambda function
resource "aws_api_gateway_method" "upload_request_method" {
  rest_api_id   = var.api_root.id
  resource_id   = aws_api_gateway_resource.upload_request_endpoint.id
  http_method   = local.upload_request_http_method 
  authorization = "NONE" // No authentication required to access the API
} 

# Lambda function for handling image retrieval requests
# This function processes GET requests to retrieve image data from storage
module "upload_request_lambda" {
    source = "../../composables/lambda/"
    lambda_function_name = local.upload_request_function_name
    lambda_folder_name = local.upload_request_function_folder
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
module "upload_request_lambda_integration" {
    source = "../../composables/api-lambda-integration/"
    rest_api = var.api_root
    resource_id = aws_api_gateway_resource.upload_request_endpoint.id
    http_method = aws_api_gateway_method.upload_request_method.http_method
    integration_http_method = "POST"  
    uri = module.upload_request_lambda.invoke_arn  
    lambda_function_name = module.upload_request_lambda.function_name
    endpoint_path = local.upload_request_endpoint
}

output "lambda_integration" {
    description = "Integration details for the upload request Lambda function"
    value = module.upload_request_lambda_integration.lambda_integration
}

  