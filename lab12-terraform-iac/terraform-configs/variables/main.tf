# Configure AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Random suffix
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# S3 Bucket with variables
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "${var.username}-terraform-bucket-${random_string.suffix.result}"
  
  tags = merge(var.common_tags, {
    Name        = "${var.username}-terraform-bucket"
    Environment = var.environment
    Owner       = var.username
  })
}

# Security Group with variables
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.username}-terraform-sg"
  description = "Terraform lab security group for ${var.environment}"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name        = "${var.username}-terraform-sg"
    Environment = var.environment
    Owner       = var.username
  })
}

# AMI data source
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 Instance with variables
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Infrastructure as Code with Terraform</h1>" > /var/www/html/index.html
              echo "<p>Deployed by: ${var.username}</p>" >> /var/www/html/index.html
              echo "<p>Environment: ${var.environment}</p>" >> /var/www/html/index.html
              echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
              EOF
  
  tags = merge(var.common_tags, {
    Name        = "${var.username}-terraform-instance"
    Environment = var.environment
    Owner       = var.username
  })
}
