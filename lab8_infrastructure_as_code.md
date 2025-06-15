# Lab 8: Infrastructure as Code with Terraform
## Basic Introduction to Terraform with AWS

**Duration:** 45 minutes  
**Prerequisites:** Have a running EC2 instance (public) or use CloudShell

### Learning Objectives
By the end of this lab, you will be able to:
- Install and configure Terraform on EC2/CloudShell
- Create basic Terraform configurations for AWS resources
- Use variables and outputs in Terraform
- Apply, modify, and destroy infrastructure with Terraform
- Understand Terraform state management
- Follow Infrastructure as Code best practices
- Compare Terraform with AWS CloudFormation

### Architecture Overview
You will use Terraform to create and manage AWS infrastructure including:
- **Basic Resources:** S3 buckets, EC2 instances
- **Networking:** VPC, subnets, security groups
- **Variable Management:** Using .tfvars files for different environments
- **State Management:** Understanding Terraform state files

### Part 1: Install and Configure Terraform

#### Step 1: Connect to Your Environment
**Option A: Using existing EC2 instance**
1. Connect to your public EC2 instance using EC2 Instance Connect
2. Ensure you're connected as ec2-user

**Option B: Using CloudShell**
1. Open AWS CloudShell from the console
2. Wait for the environment to initialize

#### Step 2: Install Terraform
1. Add HashiCorp repository and install Terraform:
   ```bash
   sudo yum install -y yum-utils
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   sudo yum -y install terraform
   ```

2. Verify installation:
   ```bash
   terraform --version
   ```

3. Enable auto-completion:
   ```bash
   terraform -install-autocomplete
   source ~/.bashrc
   ```

#### Step 3: Configure AWS CLI (if using EC2)
1. If using EC2, ensure AWS CLI is configured:
   ```bash
   aws configure list
   aws sts get-caller-identity
   ```

2. If not configured, set up credentials:
   ```bash
   aws configure
   # Enter your access key, secret key, region (us-east-1), and output format (json)
   ```

### Part 2: Create Your First Terraform Configuration

#### Step 1: Set Up Project Directory
1. Create and navigate to project directory:
   ```bash
   mkdir tf-lab
   cd tf-lab
   ```

#### Step 2: Create Initial Configuration
1. Create your first Terraform configuration file:
   ```bash
   cat > initial-main.tf << 'EOF'
   # Configure the AWS Provider
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }
   
   # Configure the AWS Provider
   provider "aws" {
     region = "us-east-1"
   }
   
   # Create an S3 bucket
   resource "aws_s3_bucket" "terraform_demo" {
     bucket = "terraform-demo-bucket-${random_string.bucket_suffix.result}"
   }
   
   # Generate random string for unique bucket name
   resource "random_string" "bucket_suffix" {
     length  = 8
     special = false
     upper   = false
   }
   
   # Configure bucket versioning
   resource "aws_s3_bucket_versioning" "terraform_demo_versioning" {
     bucket = aws_s3_bucket.terraform_demo.id
     versioning_configuration {
       status = "Enabled"
     }
   }
   
   # Configure bucket server-side encryption
   resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_demo_encryption" {
     bucket = aws_s3_bucket.terraform_demo.id
   
     rule {
       apply_server_side_encryption_by_default {
         sse_algorithm = "AES256"
       }
     }
   }
   
   # Output the bucket name
   output "bucket_name" {
     description = "Name of the S3 bucket"
     value       = aws_s3_bucket.terraform_demo.id
   }
   
   # Output the bucket ARN
   output "bucket_arn" {
     description = "ARN of the S3 bucket"
     value       = aws_s3_bucket.terraform_demo.arn
   }
   EOF
   ```

#### Step 3: Initialize and Apply Configuration
1. Initialize Terraform (downloads providers):
   ```bash
   terraform init
   ```

2. Validate the configuration:
   ```bash
   terraform validate
   ```

3. See what Terraform will create:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

5. Verify the resource in AWS Management Console:
   - Navigate to S3 service
   - Find your newly created bucket
   - Check its properties (versioning, encryption)

#### Step 4: Destroy Resources
1. Clean up the resources:
   ```bash
   terraform destroy
   ```
   Type `yes` when prompted.

2. Remove the initial configuration:
   ```bash
   rm initial-main.tf
   ```

### Part 3: Working with Variables

#### Step 1: Create Variables Configuration
1. Create a variables file:
   ```bash
   cat > variables.tf << 'EOF'
   # Variable definitions
   variable "region" {
     description = "AWS region"
     type        = string
     default     = "us-east-1"
   }
   
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "project_name" {
     description = "Name of the project"
     type        = string
     default     = "terraform-lab"
   }
   
   variable "bucket_name" {
     description = "Name of the S3 bucket"
     type        = string
     default     = ""
   }
   
   variable "enable_versioning" {
     description = "Enable versioning on S3 bucket"
     type        = bool
     default     = true
   }
   
   variable "tags" {
     description = "Tags to apply to resources"
     type        = map(string)
     default = {
       Environment = "dev"
       Project     = "terraform-lab"
       ManagedBy   = "terraform"
     }
   }
   EOF
   ```

#### Step 2: Create Main Configuration Using Variables
1. Create the main configuration file:
   ```bash
   cat > vars-main.tf << 'EOF'
   # Configure Terraform and providers
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
       random = {
         source  = "hashicorp/random"
         version = "~> 3.1"
       }
     }
   }
   
   # Configure the AWS Provider
   provider "aws" {
     region = var.region
   }
   
   # Generate random string for unique naming
   resource "random_string" "suffix" {
     length  = 8
     special = false
     upper   = false
   }
   
   # Create S3 bucket with variable-based naming
   resource "aws_s3_bucket" "main" {
     bucket = var.bucket_name != "" ? var.bucket_name : "${var.project_name}-${var.environment}-${random_string.suffix.result}"
     
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-bucket"
     })
   }
   
   # Configure bucket versioning based on variable
   resource "aws_s3_bucket_versioning" "main" {
     bucket = aws_s3_bucket.main.id
     versioning_configuration {
       status = var.enable_versioning ? "Enabled" : "Disabled"
     }
   }
   
   # Block public access
   resource "aws_s3_bucket_public_access_block" "main" {
     bucket = aws_s3_bucket.main.id
   
     block_public_acls       = true
     block_public_policy     = true
     ignore_public_acls      = true
     restrict_public_buckets = true
   }
   
   # Create a simple text object in the bucket
   resource "aws_s3_object" "sample_file" {
     bucket = aws_s3_bucket.main.id
     key    = "sample-file.txt"
     content = "This file was created by Terraform!\nEnvironment: ${var.environment}\nProject: ${var.project_name}\nTimestamp: ${timestamp()}"
     
     tags = var.tags
   }
   
   # Create an IAM role for demonstration
   resource "aws_iam_role" "s3_access_role" {
     name = "${var.project_name}-${var.environment}-s3-role"
   
     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Action = "sts:AssumeRole"
           Effect = "Allow"
           Principal = {
             Service = "ec2.amazonaws.com"
           }
         }
       ]
     })
   
     tags = var.tags
   }
   
   # Attach policy to the IAM role
   resource "aws_iam_role_policy" "s3_access_policy" {
     name = "${var.project_name}-${var.environment}-s3-policy"
     role = aws_iam_role.s3_access_role.id
   
     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Effect = "Allow"
           Action = [
             "s3:GetObject",
             "s3:PutObject",
             "s3:DeleteObject"
           ]
           Resource = "${aws_s3_bucket.main.arn}/*"
         },
         {
           Effect = "Allow"
           Action = [
             "s3:ListBucket"
           ]
           Resource = aws_s3_bucket.main.arn
         }
       ]
     })
   }
   EOF
   ```

#### Step 3: Create Outputs Configuration
1. Create outputs file:
   ```bash
   cat > outputs.tf << 'EOF'
   # Output values
   output "bucket_name" {
     description = "Name of the created S3 bucket"
     value       = aws_s3_bucket.main.id
   }
   
   output "bucket_arn" {
     description = "ARN of the S3 bucket"
     value       = aws_s3_bucket.main.arn
   }
   
   output "bucket_domain_name" {
     description = "Bucket domain name"
     value       = aws_s3_bucket.main.bucket_domain_name
   }
   
   output "iam_role_arn" {
     description = "ARN of the IAM role"
     value       = aws_iam_role.s3_access_role.arn
   }
   
   output "iam_role_name" {
     description = "Name of the IAM role"
     value       = aws_iam_role.s3_access_role.name
   }
   
   output "sample_file_key" {
     description = "Key of the sample file"
     value       = aws_s3_object.sample_file.key
   }
   
   output "environment_info" {
     description = "Environment information"
     value = {
       environment = var.environment
       project     = var.project_name
       region      = var.region
     }
   }
   EOF
   ```

#### Step 4: Create Variable Values File
1. Create a testing variables file:
   ```bash
   cat > testing.tfvars << 'EOF'
   # Testing environment variables
   region         = "us-east-1"
   environment    = "testing"
   project_name   = "aws-course"
   bucket_name    = ""  # Let Terraform generate the name
   enable_versioning = true
   
   tags = {
     Environment = "testing"
     Project     = "aws-course"
     ManagedBy   = "terraform"
     Course      = "3-day-aws-architecture"
     CreatedBy   = "student"
   }
   EOF
   ```

#### Step 5: Apply Configuration with Variables
1. Initialize the new configuration:
   ```bash
   terraform init
   ```

2. Validate the configuration:
   ```bash
   terraform validate
   ```

3. Plan with variable file:
   ```bash
   terraform plan -var-file="testing.tfvars"
   ```

4. Apply with variable file:
   ```bash
   terraform apply -var-file="testing.tfvars"
   ```
   Type `yes` when prompted.

5. View outputs:
   ```bash
   terraform output
   ```

6. View specific output:
   ```bash
   terraform output bucket_name
   terraform output -json
   ```

### Part 4: Create VPC Infrastructure

#### Step 1: Clean Up Previous Resources
1. Destroy current resources:
   ```bash
   terraform destroy -var-file="testing.tfvars"
   ```

2. Remove current files:
   ```bash
   rm vars-main.tf
   ```

#### Step 2: Create VPC Configuration
1. Create VPC main configuration:
   ```bash
   cat > main.tf << 'EOF'
   # Configure Terraform and providers
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }
   
   # Configure the AWS Provider
   provider "aws" {
     region = var.region
   }
   
   # Create VPC
   resource "aws_vpc" "main" {
     cidr_block           = var.vpc_cidr
     enable_dns_hostnames = true
     enable_dns_support   = true
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-vpc"
     })
   }
   
   # Create Internet Gateway
   resource "aws_internet_gateway" "main" {
     vpc_id = aws_vpc.main.id
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-igw"
     })
   }
   
   # Create public subnet in first AZ
   resource "aws_subnet" "public_1" {
     vpc_id                  = aws_vpc.main.id
     cidr_block              = var.public_subnet_1_cidr
     availability_zone       = data.aws_availability_zones.available.names[0]
     map_public_ip_on_launch = true
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-public-subnet-1"
       Type = "Public"
     })
   }
   
   # Create public subnet in second AZ
   resource "aws_subnet" "public_2" {
     vpc_id                  = aws_vpc.main.id
     cidr_block              = var.public_subnet_2_cidr
     availability_zone       = data.aws_availability_zones.available.names[1]
     map_public_ip_on_launch = true
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-public-subnet-2"
       Type = "Public"
     })
   }
   
   # Create private subnet in first AZ
   resource "aws_subnet" "private_1" {
     vpc_id            = aws_vpc.main.id
     cidr_block        = var.private_subnet_1_cidr
     availability_zone = data.aws_availability_zones.available.names[0]
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-private-subnet-1"
       Type = "Private"
     })
   }
   
   # Create private subnet in second AZ
   resource "aws_subnet" "private_2" {
     vpc_id            = aws_vpc.main.id
     cidr_block        = var.private_subnet_2_cidr
     availability_zone = data.aws_availability_zones.available.names[1]
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-private-subnet-2"
       Type = "Private"
     })
   }
   
   # Create route table for public subnets
   resource "aws_route_table" "public" {
     vpc_id = aws_vpc.main.id
   
     route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main.id
     }
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-public-rt"
     })
   }
   
   # Associate public subnets with public route table
   resource "aws_route_table_association" "public_1" {
     subnet_id      = aws_subnet.public_1.id
     route_table_id = aws_route_table.public.id
   }
   
   resource "aws_route_table_association" "public_2" {
     subnet_id      = aws_subnet.public_2.id
     route_table_id = aws_route_table.public.id
   }
   
   # Create security group for web servers
   resource "aws_security_group" "web" {
     name_prefix = "${var.project_name}-${var.environment}-web-"
     vpc_id      = aws_vpc.main.id
   
     # HTTP access
     ingress {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
   
     # HTTPS access
     ingress {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
   
     # SSH access
     ingress {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = [var.vpc_cidr]
     }
   
     # All outbound traffic
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
   
     tags = merge(var.tags, {
       Name = "${var.project_name}-${var.environment}-web-sg"
     })
   }
   
   # Data source for availability zones
   data "aws_availability_zones" "available" {
     state = "available"
   }
   
   # Data source for latest Amazon Linux 2 AMI
   data "aws_ami" "amazon_linux" {
     most_recent = true
     owners      = ["amazon"]
   
     filter {
       name   = "name"
       values = ["amzn2-ami-hvm-*-x86_64-gp2"]
     }
   }
   EOF
   ```

#### Step 3: Update Variables for VPC
1. Update the variables file:
   ```bash
   cat > variables.tf << 'EOF'
   # Variable definitions for VPC infrastructure
   variable "region" {
     description = "AWS region"
     type        = string
     default     = "us-east-1"
   }
   
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "project_name" {
     description = "Name of the project"
     type        = string
     default     = "terraform-lab"
   }
   
   variable "vpc_cidr" {
     description = "CIDR block for VPC"
     type        = string
     default     = "10.0.0.0/16"
   }
   
   variable "public_subnet_1_cidr" {
     description = "CIDR block for public subnet 1"
     type        = string
     default     = "10.0.1.0/24"
   }
   
   variable "public_subnet_2_cidr" {
     description = "CIDR block for public subnet 2"
     type        = string
     default     = "10.0.2.0/24"
   }
   
   variable "private_subnet_1_cidr" {
     description = "CIDR block for private subnet 1"
     type        = string
     default     = "10.0.3.0/24"
   }
   
   variable "private_subnet_2_cidr" {
     description = "CIDR block for private subnet 2"
     type        = string
     default     = "10.0.4.0/24"
   }
   
   variable "tags" {
     description = "Tags to apply to resources"
     type        = map(string)
     default = {
       Environment = "dev"
       Project     = "terraform-lab"
       ManagedBy   = "terraform"
     }
   }
   EOF
   ```

#### Step 4: Update Outputs for VPC
1. Update outputs:
   ```bash
   cat > outputs.tf << 'EOF'
   # VPC outputs
   output "vpc_id" {
     description = "ID of the VPC"
     value       = aws_vpc.main.id
   }
   
   output "vpc_cidr_block" {
     description = "CIDR block of the VPC"
     value       = aws_vpc.main.cidr_block
   }
   
   output "internet_gateway_id" {
     description = "ID of the Internet Gateway"
     value       = aws_internet_gateway.main.id
   }
   
   output "public_subnet_ids" {
     description = "IDs of the public subnets"
     value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
   }
   
   output "private_subnet_ids" {
     description = "IDs of the private subnets"
     value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
   }
   
   output "security_group_id" {
     description = "ID of the web security group"
     value       = aws_security_group.web.id
   }
   
   output "availability_zones" {
     description = "Availability zones used"
     value       = [aws_subnet.public_1.availability_zone, aws_subnet.public_2.availability_zone]
   }
   
   output "amazon_linux_ami_id" {
     description = "ID of the latest Amazon Linux 2 AMI"
     value       = data.aws_ami.amazon_linux.id
   }
   EOF
   ```

#### Step 5: Create VPC-Specific Variable File
1. Create production-like variable file:
   ```bash
   cat > vpc.tfvars << 'EOF'
   # VPC configuration variables
   region                  = "us-east-1"
   environment            = "production"
   project_name           = "aws-course"
   vpc_cidr               = "10.192.0.0/16"
   public_subnet_1_cidr   = "10.192.10.0/24"
   public_subnet_2_cidr   = "10.192.11.0/24"
   private_subnet_1_cidr  = "10.192.20.0/24"
   private_subnet_2_cidr  = "10.192.21.0/24"
   
   tags = {
     Environment = "production"
     Project     = "aws-course"
     ManagedBy   = "terraform"
     Course      = "3-day-aws-architecture"
     CreatedBy   = "student"
     Purpose     = "learning-vpc-infrastructure"
   }
   EOF
   ```

### Part 5: Apply VPC Configuration

#### Step 1: Deploy VPC Infrastructure
1. Initialize and validate:
   ```bash
   terraform init
   terraform validate
   ```

2. Plan the deployment:
   ```bash
   terraform plan -var-file="vpc.tfvars"
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var-file="vpc.tfvars"
   ```
   Type `yes` when prompted.

4. Review outputs:
   ```bash
   terraform output
   ```

#### Step 2: Verify in AWS Console
1. Navigate to **VPC** service in AWS Console
2. Verify the following were created:
   - VPC with correct CIDR block
   - 4 subnets (2 public, 2 private) in different AZs
   - Internet Gateway attached to VPC
   - Route table with internet route for public subnets
   - Security group with appropriate rules

### Part 6: Terraform State Management

#### Step 1: Examine Terraform State
1. View state file:
   ```bash
   terraform show
   ```

2. List resources in state:
   ```bash
   terraform state list
   ```

3. Show specific resource details:
   ```bash
   terraform state show aws_vpc.main
   ```

#### Step 2: Make Infrastructure Changes
1. Edit the `vpc.tfvars` file to add a tag:
   ```bash
   cat >> vpc.tfvars << 'EOF'
   
   # Additional tag for demonstration
   additional_tag = "modified-infrastructure"
   EOF
   ```

2. Update variables.tf to include the new variable:
   ```bash
   cat >> variables.tf << 'EOF'
   
   variable "additional_tag" {
     description = "Additional tag for demonstration"
     type        = string
     default     = ""
   }
   EOF
   ```

3. Update main.tf to use the new tag (modify VPC tags):
   ```bash
   # This is just for demonstration - in practice, you'd edit the file
   echo "# Note: In practice, you would edit the main.tf file to add the new tag to resources"
   ```

4. Plan and apply changes:
   ```bash
   terraform plan -var-file="vpc.tfvars"
   # terraform apply -var-file="vpc.tfvars"  # Uncomment to apply
   ```

### Part 7: Working with Multiple Environments

#### Step 1: Create Development Environment Variables
1. Create dev environment configuration:
   ```bash
   cat > dev.tfvars << 'EOF'
   # Development environment variables
   region                  = "us-east-1"
   environment            = "development"
   project_name           = "aws-course"
   vpc_cidr               = "10.0.0.0/16"
   public_subnet_1_cidr   = "10.0.1.0/24"
   public_subnet_2_cidr   = "10.0.2.0/24"
   private_subnet_1_cidr  = "10.0.3.0/24"
   private_subnet_2_cidr  = "10.0.4.0/24"
   
   tags = {
     Environment = "development"
     Project     = "aws-course"
     ManagedBy   = "terraform"
     Course      = "3-day-aws-architecture"
     CreatedBy   = "student"
     Purpose     = "learning-development"
   }
   EOF
   ```

#### Step 2: Demonstrate Environment Switching
1. Plan for development environment:
   ```bash
   terraform plan -var-file="dev.tfvars"
   ```

2. Note the differences in resource names and configurations

### Part 8: Terraform Best Practices

#### Step 1: Formatting and Validation
1. Format your Terraform files:
   ```bash
   terraform fmt
   ```

2. Validate configuration:
   ```bash
   terraform validate
   ```

#### Step 2: Create a .gitignore File
1. Create .gitignore for version control:
   ```bash
   cat > .gitignore << 'EOF'
   # Terraform files to ignore
   *.tfstate
   *.tfstate.*
   *.tfvars
   .terraform/
   .terraform.lock.hcl
   
   # Crash log files
   crash.log
   
   # Exclude all .tfvars files, which are likely to contain sensitive data
   *.tfvars
   *.tfvars.json
   
   # Override files as they are usually used to override resources locally
   override.tf
   override.tf.json
   *_override.tf
   *_override.tf.json
   
   # Include override files you do wish to add to version control using negated pattern
   # !example_override.tf
   
   # Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
   *tfplan*
   
   # Ignore CLI configuration files
   .terraformrc
   terraform.rc
   EOF
   ```

### Part 9: Compare with CloudFormation

#### Step 1: Create Equivalent CloudFormation Template
1. Create a basic CloudFormation template for comparison:
   ```bash
   cat > vpc-cloudformation.yaml << 'EOF'
   AWSTemplateFormatVersion: '2010-09-09'
   Description: 'VPC Infrastructure - CloudFormation equivalent'
   
   Parameters:
     VpcCIDR:
       Type: String
       Default: '10.192.0.0/16'
     
   Resources:
     VPC:
       Type: AWS::EC2::VPC
       Properties:
         CidrBlock: !Ref VpcCIDR
         EnableDnsHostnames: true
         EnableDnsSupport: true
         Tags:
           - Key: Name
             Value: CloudFormation-VPC
   
     InternetGateway:
       Type: AWS::EC2::InternetGateway
       Properties:
         Tags:
           - Key: Name
             Value: CloudFormation-IGW
   
     AttachGateway:
       Type: AWS::EC2::VPCGatewayAttachment
       Properties:
         VpcId: !Ref VPC
         InternetGatewayId: !Ref InternetGateway
   
   Outputs:
     VPCId:
       Description: VPC ID
       Value: !Ref VPC
   EOF
   ```

#### Step 2: Compare Tools
1. Create comparison document:
   ```bash
   cat > terraform-vs-cloudformation.md << 'EOF'
   # Terraform vs CloudFormation Comparison
   
   ## Terraform Advantages:
   - Multi-cloud support (AWS, Azure, GCP, etc.)
   - Rich expression language (HCL)
   - Larger ecosystem of providers
   - Built-in functions and data sources
   - Plan preview before apply
   - State management flexibility
   
   ## CloudFormation Advantages:
   - Native AWS service (no additional tools)
   - Free to use (no licensing costs)
   - Deeper AWS service integration
   - Built-in rollback capabilities
   - AWS Support included
   - Stack dependencies and cross-stack references
   
   ## Use Cases:
   - **Terraform**: Multi-cloud, complex logic, existing Terraform expertise
   - **CloudFormation**: AWS-only, simple deployments, AWS-native teams
   EOF
   ```

### Part 10: Cleanup and Best Practices

#### Step 1: Destroy Infrastructure
1. Destroy all created resources:
   ```bash
   terraform destroy -var-file="vpc.tfvars"
   ```
   Type `yes` when prompted.

2. Verify destruction in AWS Console

#### Step 2: Review Project Structure
1. List all files created:
   ```bash
   ls -la
   ```

2. Review project structure:
   ```bash
   tree . || ls -la
   ```

#### Step 3: Document Learning
1. Create a summary of what was learned:
   ```bash
   cat > terraform-learning-summary.md << 'EOF'
   # Terraform Learning Summary
   
   ## Key Concepts Learned:
   1. **Infrastructure as Code**: Managing infrastructure through code
   2. **Terraform Configuration**: HCL syntax and resource definitions
   3. **Variables and Outputs**: Making configurations reusable
   4. **State Management**: Understanding Terraform state files
   5. **Environment Management**: Using .tfvars files for different environments
   6. **Best Practices**: Formatting, validation, and version control
   
   ## Commands Mastered:
   - `terraform init`: Initialize working directory
   - `terraform plan`: Preview changes
   - `terraform apply`: Apply changes
   - `terraform destroy`: Destroy infrastructure
   - `terraform fmt`: Format configuration files
   - `terraform validate`: Validate configuration
   - `terraform output`: Display output values
   - `terraform state`: Manage state file
   
   ## Real-World Applications:
   - Consistent environment provisioning
   - Infrastructure versioning and rollbacks
   - Multi-environment management (dev/test/prod)
   - Disaster recovery and infrastructure replication
   - Cost optimization through automated teardown
   EOF
   ```

### Key Concepts Learned

**Infrastructure as Code (IaC):**
- Version-controlled infrastructure definitions
- Repeatable and consistent deployments
- Automated provisioning and management
- Documentation through code

**Terraform Fundamentals:**
- HCL (HashiCorp Configuration Language) syntax
- Resource blocks and dependencies
- Provider configuration and authentication
- State file management and importance

**Configuration Management:**
- Variables for reusable configurations
- Output values for resource information
- Environment-specific variable files
- Modular and maintainable code structure

**AWS Resource Management:**
- VPC and networking components
- Security groups and access control
- Multi-AZ deployment patterns
- Resource naming and tagging strategies

**Operational Practices:**
- Planning before applying changes
- State management and backup strategies
- Environment isolation techniques
- Cleanup and resource lifecycle management

### Troubleshooting Tips

**Terraform initialization issues:**
- Ensure internet connectivity for provider downloads
- Check AWS credentials and permissions
- Verify Terraform version compatibility

**Resource creation failures:**
- Check AWS service limits and quotas
- Verify IAM permissions for required actions
- Review CIDR block conflicts
- Ensure unique resource names

**State file problems:**
- Never manually edit state files
- Use `terraform state` commands for modifications
- Backup state files before major changes
- Consider remote state storage for teams

**Variable and syntax errors:**
- Use `terraform validate` to check syntax
- Use `terraform fmt` to maintain consistent formatting
- Check variable types and constraints
- Review provider documentation for resource arguments

### Next Steps

**Advanced Terraform Topics:**
- Remote state storage (S3 + DynamoDB)
- Terraform modules for reusability
- Workspaces for environment management
- CI/CD integration with Terraform

**Production Considerations:**
- State locking and team collaboration
- Sensitive data management
- Infrastructure monitoring and alerting
- Backup and disaster recovery strategies

**Integration Opportunities:**
- Combining Terraform with AWS CodePipeline
- Using Terraform with container orchestration
- Multi-cloud deployments
- Compliance and governance automation

This lab provided hands-on experience with Infrastructure as Code using Terraform, demonstrating how to automate AWS infrastructure deployment, manage multiple environments, and follow best practices for maintainable infrastructure code.