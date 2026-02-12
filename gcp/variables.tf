variable "project_id" {
  type        = string
  description = "GCP Project ID (e.g., csye6225-demo-487215)"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-east1"
}

variable "zones" {
  type        = list(string)
  description = "3 zones in the region (one public + one private subnet per zone)"
  default     = ["us-east1-b", "us-east1-c", "us-east1-d"]
}

variable "project" {
  type        = string
  description = "Prefix for resource naming"
  default     = "csye6225"
}

variable "env" {
  type        = string
  description = "Environment name (dev/demo)"
  default     = "demo"
}

variable "name_suffix" {
  type        = string
  description = "Suffix so you can create multiple VPCs in same project/region (e.g., v1, v2)"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for 3 public subnets"
  default     = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for 3 private subnets"
  default     = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
}

variable "app_port" {
  type        = number
  description = "App port to allow inbound on instances tagged 'app'"
  default     = 8080
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to SSH (use your public IPv4 /32). Keep as a list."
  default     = []
}