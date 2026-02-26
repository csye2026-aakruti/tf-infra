variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Project name prefix for tagging/naming"
  default     = "csye6225"
}

variable "env" {
  type        = string
  description = "Environment name (dev/demo)"
  default     = "dev"
}

variable "name_suffix" {
  type        = string
  description = "Suffix so you can create multiple VPCs in same account/region"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets (3)"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets (3)"
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
variable "app_port" {
  type        = number
  description = "Port your webapp listens on"
  default     = 8080
}

variable "ssh_public_key" {
  description = "SSH public key contents for EC2 key pair"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to EC2 (your public IP /32)"
  type        = string
}

variable "db_name" {
  type        = string
  description = "RDS database name"
  default     = "webapp"
}

variable "db_username" {
  type        = string
  description = "RDS master username"
  default     = "webappuser"
}

variable "db_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}

variable "db_master_password" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type        = string
  description = "JWT secret for the web application"
  sensitive   = true
}

variable "custom_ami_id" {
  type        = string
  description = "Custom AMI ID built by Packer"
}