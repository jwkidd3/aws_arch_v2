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

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# S3 Bucket
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "USERNAME-terraform-bucket-${random_string.suffix.result}"
  
  tags = {
    Name      = "USERNAME-terraform-bucket"
    ManagedBy = "Terraform"
    Owner     = "USERNAME"
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name_prefix = "USERNAME-terraform-sg"
  description = "Terraform lab security group"
  
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
  
  tags = {
    Name      = "USERNAME-terraform-sg"
    ManagedBy = "Terraform"
    Owner     = "USERNAME"
  }
}

# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Infrastructure as Code with Terraform</h1>" > /var/www/html/index.html
              echo "<p>Deployed by: USERNAME</p>" >> /var/www/html/index.html
              echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
              EOF
  
  tags = {
    Name      = "USERNAME-terraform-instance"
    ManagedBy = "Terraform"
    Owner     = "USERNAME"
  }
}
