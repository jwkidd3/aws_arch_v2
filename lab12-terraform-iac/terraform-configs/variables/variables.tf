variable "username" {
  description = "Username for resource naming"
  type        = string
  default     = "USERNAME"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    ManagedBy = "Terraform"
    Project   = "AWS-Architecting-Course"
  }
}
