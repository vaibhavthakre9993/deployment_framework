variable "app_name" {
  description = "Application name"
  type        = string
}

variable "port" {
  description = "Application port"
  type        = number
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group" {
  description = "Resource Group Name"
  type        = string
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
}
