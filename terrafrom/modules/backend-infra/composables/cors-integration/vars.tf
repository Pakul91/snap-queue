variable "api_root" {
  description = "Root resource of the API Gateway"
  type = object({
    id            = string
    root_resource_id = string
    execution_arn = string
  })
}

variable "resource_id" {
  description = "ID of the resource to add CORS support to"
  type        = string
}

variable "allowed_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "allowed_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "allowed_origin" {
  description = "Allowed origin for CORS"
  type        = string
  default     = "*"
}

variable "allowed_credentials" {
  description = "Whether to allow credentials for CORS requests"
  type        = bool
  default     = false
}