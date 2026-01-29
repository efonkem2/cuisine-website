variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-pipeline"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your IP for better security
}

variable "instance_type_runner" {
  description = "Instance type for GitHub runner"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_nexus_sonar" {
  description = "Instance type for Nexus and SonarQube server"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_monitoring" {
  description = "Instance type for monitoring server"
  type        = string
  default     = "t3.medium"
}

variable "public_key" {
  description = "Public key for EC2 instances"
  type        = string
  # Generate with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops-pipeline
}

variable "github_token" {
  description = "GitHub personal access token for runner registration"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository URL (org/repo format)"
  type        = string
  # Example: "your-org/your-repo"
}