# terraform/variables.tf

variable "region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "ap-south-1" # Set your preferred default region
}

variable "project_name" {
  description = "A unique name for the project to tag resources"
  type        = string
  default     = "car-showcase-app"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Example: two public subnets
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"] # Example: two private subnets
}
