variable "rest_api" {
  description = "Rest API for which the integration is being created"
  type = object({
    id   = string
    execution_arn = string
  })
}

variable "resource_id" {
  description = "The ID of the API Gateway resource to integrate with"
  type        = string
}

variable "http_method" {
  description = "The HTTP method for the API Gateway integration"
  type        = string
}

variable "integration_http_method" {
  description = "The HTTP method used for the integration (usually POST)"
  type        = string
  default     = "POST"
}

variable "type" {
  description = "The type of integration (default is AWS_PROXY)"
  type        = string
  default     = "AWS_PROXY"
}

variable "uri" {
  description = "The URI of the Lambda function to integrate with"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to integrate with"
  type        = string
}

variable "endpoint_path" {
  description = "Path of the API endpoint that this integration is for"
  type        = string
}

