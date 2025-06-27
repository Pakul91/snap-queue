variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "default"
}

variable "log_level" {
  description = "Logging level for the application"
  type        = string
  default     = "info"
}

variable "cors_origin" {
  description = "CORS origin for the application"
  type        = string
  default     = "*"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_networking_module" {
  description = "Whether to enable the serverless API module"
  type        = bool
  default     = true
}