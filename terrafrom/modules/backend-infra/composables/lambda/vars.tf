variable "lambda_function_name" {
  description = "Name of the Lambda function with environment suffix"
  type        = string
}

variable "lambda_folder_name" {
  description = "Name of the folder containing the Lambda function code"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "nodejs22.x"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "lambda_layers" {
  description = "ARN of the Lambda layer to include"
  type        = list(string)
  default     = []
}

variable "env_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "Environment for the Lambda function (e.g., dev, prod)"
  type        = string
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}


variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "Namespace for the Lambda function"
  type        = string
  default     = "default"
}

