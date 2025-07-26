#!/bin/bash

# Lab 12 Setup Script: Infrastructure as Code with Terraform
# AWS Architecting Course - Day 3, Session 4
# Duration: 45 minutes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}================================================${NC}"
}

# Username placeholder - students will update this in lab instructions
USERNAME="USERNAME"

# Main function
main() {
    print_header "AWS Architecting Course - Lab 12 Setup"
    print_status "Setting up Infrastructure as Code with Terraform Lab"
    
    # Create lab directory structure
    LAB_DIR="lab12-terraform-iac"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
# Lab 12: Infrastructure as Code with Terraform

**Duration:** 45 minutes  
**Objective:** Learn Infrastructure as Code principles using Terraform to deploy and manage AWS resources programmatically, compare Terraform with AWS CloudFormation, and implement best practices for infrastructure automation.

## Prerequisites
- Completion of previous labs (especially Lab 1-4 for EC2 and VPC knowledge)
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Basic understanding of JSON and configuration files

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Understand Infrastructure as Code (IaC) principles and benefits
- Install and configure Terraform on EC2 instances
- Write Terraform configuration files for AWS resources
- Use Terraform variables, outputs, and modules effectively
- Compare Terraform vs CloudFormation approaches
- Implement version control and state management for infrastructure
- Deploy and destroy infrastructure programmatically

---

## Task 1: Terraform Installation and Setup (15 minutes)

### Step 1: Launch EC2 Instance for Terraform
1. **Navigate to EC2:**
   - In the AWS Management Console, go to **EC2** service
   - Click **Instances** in the left navigation menu

2. **Launch Instance:**
   - Click **Launch Instances**
   - **Name:** `USERNAME-terraform-instance` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro
   - **Key pair:** Use existing key pair or create new one: `USERNAME-terraform-key` ⚠️ **Use your username**

3. **Network Configuration:**
   - **VPC:** Default VPC
   - **Subnet:** Any available public subnet
   - **Auto-assign public IP:** Enable
   - **Security group:** Create new `USERNAME-terraform-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Rules:**
     - SSH (22) from 0.0.0.0/0

4. **Launch the Instance**

### Step 2: Connect and Install Terraform
1. **Connect to Instance:**
   - Use EC2 Instance Connect or SSH
   - Wait for instance to reach "running" state

2. **Install Terraform:**
   ```bash
   # Update system
   sudo yum update -y
   
   # Install required packages
   sudo yum install -y yum-utils unzip wget
   
   # Add HashiCorp repository
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   
   # Install Terraform
   sudo yum -y install terraform
   
   # Verify installation
   terraform version
   
   # Enable autocompletion
   terraform -install-autocomplete
   source ~/.bashrc
   ```

3. **Configure AWS CLI:**
   ```bash
   # Install AWS CLI (if not already installed)
   sudo yum install -y aws-cli
   
   # Configure AWS CLI (you'll need access keys)
   aws configure
   # When prompted, enter:
   # - Access Key ID: [Your access key]
   # - Secret Access Key: [Your secret key]
   # - Default region: us-east-1
   # - Default output format: json
   
   # Verify configuration
   aws sts get-caller-identity
   ```

### Step 3: Create Lab Directory Structure
```bash
# Create directory for Terraform projects
mkdir -p ~/terraform-lab
cd ~/terraform-lab

# Create subdirectories for different exercises
mkdir -p basic-example
mkdir -p variables-example
mkdir -p vpc-example

# Show directory structure
tree . || ls -la
```

---

## Task 2: Basic Terraform Configuration (15 minutes)

### Step 1: Create Your First Terraform Configuration
1. **Navigate to basic example directory:**
   ```bash
   cd ~/terraform-lab/basic-example
   ```

2. **Create main.tf file:**
   ```bash
   cat > main.tf << 'HCL'
   # Configure the AWS Provider
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
     required_version = ">= 1.0"
   }
   
   # Configure AWS Provider
   provider "aws" {
     region = "us-east-1"
   }
   
   # Create S3 Bucket
   resource "aws_s3_bucket" "USERNAME_terraform_bucket" {
     bucket = "USERNAME-terraform-lab-bucket-${random_string.bucket_suffix.result}"
     
     tags = {
       Name        = "USERNAME-terraform-bucket"
       Environment = "Lab"
       ManagedBy   = "Terraform"
       Owner       = "USERNAME"
     }
   }
   
   # Generate random string for bucket name uniqueness
   resource "random_string" "bucket_suffix" {
     length  = 8
     special = false
     upper   = false
   }
   
   # Configure bucket versioning
   resource "aws_s3_bucket_versioning" "USERNAME_bucket_versioning" {
     bucket = aws_s3_bucket.USERNAME_terraform_bucket.id
     versioning_configuration {
       status = "Enabled"
     }
   }
   
   # Create EC2 Security Group
   resource "aws_security_group" "USERNAME_terraform_sg" {
     name_prefix = "USERNAME-terraform-sg"
     description = "Security group created by Terraform"
     
     ingress {
       description = "SSH"
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
     
     ingress {
       description = "HTTP"
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
       Name = "USERNAME-terraform-sg"
       ManagedBy = "Terraform"
       Owner = "USERNAME"
     }
   }
   
   # Create EC2 Instance
   resource "aws_instance" "USERNAME_terraform_instance" {
     ami           = "ami-0166fe664262f664c"  # Amazon Linux 2023
     instance_type = "t2.micro"
     
     vpc_security_group_ids = [aws_security_group.USERNAME_terraform_sg.id]
     
     user_data = <<-EOF
                 #!/bin/bash
                 yum update -y
                 yum install -y httpd
                 systemctl start httpd
                 systemctl enable httpd
                 echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
                 echo "<p>Instance created by: USERNAME</p>" >> /var/www/html/index.html
                 echo "<p>Managed by: Terraform</p>" >> /var/www/html/index.html
                 EOF
     
     tags = {
       Name = "USERNAME-terraform-instance"
       ManagedBy = "Terraform"
       Owner = "USERNAME"
     }
   }
HCL
   ```

⚠️ **Important:** Replace all instances of `USERNAME` in the file with your assigned username:

```bash
# Replace USERNAME with your actual username (e.g., user1)
sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" main.tf
```

### Step 2: Deploy Infrastructure with Terraform
1. **Initialize Terraform:**
   ```bash
   # Initialize Terraform working directory
   terraform init
   
   # Validate configuration
   terraform validate
   
   # Format configuration files
   terraform fmt
   ```

2. **Plan Deployment:**
   ```bash
   # Create execution plan
   terraform plan
   
   # Review the planned changes carefully
   # This shows what Terraform will create/modify/destroy
   ```

3. **Apply Configuration:**
   ```bash
   # Apply the configuration
   terraform apply
   
   # Type 'yes' when prompted to confirm
   ```

4. **Verify Resources:**
   ```bash
   # Check Terraform state
   terraform show
   
   # List all resources
   terraform state list
   ```

### Step 3: Test Deployed Resources
1. **Verify in AWS Console:**
   - Check EC2 Instances for your new instance
   - Check S3 for your new bucket
   - Check Security Groups for your new security group

2. **Test Web Server:**
   ```bash
   # Get instance public IP
   INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null || echo "Check AWS Console for IP")
   echo "Instance IP: $INSTANCE_IP"
   
   # Test web server (wait a few minutes for user data to complete)
   curl http://$INSTANCE_IP || echo "Web server may still be starting"
   ```

---

## Task 3: Working with Variables and Outputs (15 minutes)

### Step 1: Create Variables Configuration
1. **Navigate to variables example:**
   ```bash
   cd ~/terraform-lab/variables-example
   ```

2. **Create variables.tf:**
   ```bash
   cat > variables.tf << 'HCL'
   # Input Variables
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
     
     validation {
       condition = can(regex("^t[2-3]\\.", var.instance_type))
       error_message = "Instance type must be a t2 or t3 instance."
     }
   }
   
   variable "allowed_cidr_blocks" {
     description = "CIDR blocks allowed for SSH access"
     type        = list(string)
     default     = ["0.0.0.0/0"]
   }
   
   variable "enable_monitoring" {
     description = "Enable detailed monitoring for EC2 instance"
     type        = bool
     default     = false
   }
   
   variable "common_tags" {
     description = "Common tags to apply to all resources"
     type        = map(string)
     default = {
       ManagedBy   = "Terraform"
       Environment = "Lab"
     }
   }
HCL
   ```

3. **Create outputs.tf:**
   ```bash
   cat > outputs.tf << 'HCL'
   # Output Values
   output "vpc_id" {
     description = "VPC ID where resources are created"
     value       = data.aws_vpc.default.id
   }
   
   output "security_group_id" {
     description = "Security group ID"
     value       = aws_security_group.web_sg.id
   }
   
   output "instance_id" {
     description = "EC2 instance ID"
     value       = aws_instance.web_server.id
   }
   
   output "instance_public_ip" {
     description = "Public IP address of the instance"
     value       = aws_instance.web_server.public_ip
   }
   
   output "instance_public_dns" {
     description = "Public DNS name of the instance"
     value       = aws_instance.web_server.public_dns
   }
   
   output "website_url" {
     description = "URL to access the web server"
     value       = "http://${aws_instance.web_server.public_ip}"
   }
   
   output "ssh_command" {
     description = "SSH command to connect to the instance"
     value       = "ssh -i your-key.pem ec2-user@${aws_instance.web_server.public_ip}"
   }
   
   output "resource_summary" {
     description = "Summary of created resources"
     value = {
       vpc_id            = data.aws_vpc.default.id
       instance_id       = aws_instance.web_server.id
       security_group_id = aws_security_group.web_sg.id
       public_ip         = aws_instance.web_server.public_ip
       environment       = var.environment
       managed_by        = "Terraform"
     }
   }
HCL
   ```

4. **Create main configuration with variables:**
   ```bash
   cat > main.tf << 'HCL'
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
     required_version = ">= 1.0"
   }
   
   provider "aws" {
     region = "us-east-1"
   }
   
   # Data source to get default VPC
   data "aws_vpc" "default" {
     default = true
   }
   
   # Data source to get latest Amazon Linux AMI
   data "aws_ami" "amazon_linux" {
     most_recent = true
     owners      = ["amazon"]
     
     filter {
       name   = "name"
       values = ["amzn2-ami-hvm-*-x86_64-gp2"]
     }
   }
   
   # Security Group
   resource "aws_security_group" "web_sg" {
     name_prefix = "${var.username}-${var.environment}-web-sg"
     description = "Security group for web server - managed by Terraform"
     vpc_id      = data.aws_vpc.default.id
     
     ingress {
       description = "SSH"
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = var.allowed_cidr_blocks
     }
     
     ingress {
       description = "HTTP"
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
       Name = "${var.username}-${var.environment}-web-sg"
       Owner = var.username
     })
   }
   
   # EC2 Instance
   resource "aws_instance" "web_server" {
     ami           = data.aws_ami.amazon_linux.id
     instance_type = var.instance_type
     
     vpc_security_group_ids = [aws_security_group.web_sg.id]
     monitoring             = var.enable_monitoring
     
     user_data = templatefile("${path.module}/user_data.sh", {
       username    = var.username
       environment = var.environment
     })
     
     tags = merge(var.common_tags, {
       Name = "${var.username}-${var.environment}-web-server"
       Owner = var.username
     })
   }
HCL
   ```

5. **Create user data script:**
   ```bash
   cat > user_data.sh << 'BASH'
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   
   # Create custom index page
   cat > /var/www/html/index.html << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Terraform Lab - ${username}</title>
       <style>
           body { font-family: Arial, sans-serif; text-align: center; background: #f0f8ff; padding: 50px; }
           .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: inline-block; }
           .terraform { color: #623ce4; }
           .aws { color: #ff9900; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>🚀 Infrastructure as Code with <span class="terraform">Terraform</span></h1>
           <h2>Deployed on <span class="aws">AWS</span></h2>
           <p><strong>Owner:</strong> ${username}</p>
           <p><strong>Environment:</strong> ${environment}</p>
           <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
           <p><strong>Deployment Time:</strong> $(date)</p>
           <div style="margin-top: 20px; padding: 15px; background: #e8f5e8; border-radius: 5px;">
               <p>✅ This infrastructure was deployed using Terraform</p>
               <p>🔧 Infrastructure as Code makes deployments repeatable and reliable</p>
           </div>
       </div>
   </body>
   </html>
HTML
   
   # Set proper permissions
   chown apache:apache /var/www/html/index.html
   chmod 644 /var/www/html/index.html
BASH
   ```

6. **Create terraform.tfvars file:**
   ```bash
   cat > terraform.tfvars << 'HCL'
   # Replace USERNAME with your assigned username
   username = "USERNAME"
   environment = "production"
   instance_type = "t2.micro"
   enable_monitoring = true
   
   allowed_cidr_blocks = ["0.0.0.0/0"]
   
   common_tags = {
     ManagedBy   = "Terraform"
     Environment = "Production"
     Project     = "AWS-Architecting-Course"
     Owner       = "USERNAME"
   }
HCL
   
   # Replace USERNAME with your actual username
   sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" terraform.tfvars
   sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" variables.tf
   ```

### Step 2: Deploy with Variables
1. **Initialize and Deploy:**
   ```bash
   terraform init
   terraform validate
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

2. **Test Outputs:**
   ```bash
   # Display all outputs
   terraform output
   
   # Display specific output
   terraform output website_url
   terraform output instance_public_ip
   terraform output resource_summary
   
   # Test the website
   curl $(terraform output -raw website_url)
   ```

### Step 3: Modify and Update Infrastructure
1. **Update variables:**
   ```bash
   # Create a new tfvars file for different configuration
   cat > dev.tfvars << 'HCL'
   username = "YOUR_USERNAME_HERE"
   environment = "development"
   instance_type = "t2.micro"
   enable_monitoring = false
   
   common_tags = {
     ManagedBy   = "Terraform"
     Environment = "Development"
     Project     = "AWS-Architecting-Course"
   }
HCL
   ```

2. **Apply changes:**
   ```bash
   # Plan with new variables
   terraform plan -var-file="dev.tfvars"
   
   # Apply changes
   terraform apply -var-file="dev.tfvars"
   ```

---

## Advanced Exercise: VPC Creation with Terraform

### Create a Complete VPC Infrastructure
1. **Navigate to VPC example:**
   ```bash
   cd ~/terraform-lab/vpc-example
   ```

2. **Create comprehensive VPC configuration:**
   ```bash
   cat > vpc-main.tf << 'HCL'
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
     required_version = ">= 1.0"
   }
   
   provider "aws" {
     region = "us-east-1"
   }
   
   # Variables
   variable "username" {
     description = "Username for resource naming"
     type        = string
     default     = "USERNAME"
   }
   
   variable "vpc_cidr" {
     description = "CIDR block for VPC"
     type        = string
     default     = "10.0.0.0/16"
   }
   
   # VPC
   resource "aws_vpc" "main" {
     cidr_block           = var.vpc_cidr
     enable_dns_hostnames = true
     enable_dns_support   = true
     
     tags = {
       Name = "${var.username}-terraform-vpc"
       ManagedBy = "Terraform"
     }
   }
   
   # Internet Gateway
   resource "aws_internet_gateway" "main" {
     vpc_id = aws_vpc.main.id
     
     tags = {
       Name = "${var.username}-terraform-igw"
       ManagedBy = "Terraform"
     }
   }
   
   # Public Subnet
   resource "aws_subnet" "public" {
     vpc_id                  = aws_vpc.main.id
     cidr_block              = "10.0.1.0/24"
     availability_zone       = "us-east-1a"
     map_public_ip_on_launch = true
     
     tags = {
       Name = "${var.username}-terraform-public-subnet"
       ManagedBy = "Terraform"
     }
   }
   
   # Private Subnet
   resource "aws_subnet" "private" {
     vpc_id            = aws_vpc.main.id
     cidr_block        = "10.0.2.0/24"
     availability_zone = "us-east-1b"
     
     tags = {
       Name = "${var.username}-terraform-private-subnet"
       ManagedBy = "Terraform"
     }
   }
   
   # Route Table for Public Subnet
   resource "aws_route_table" "public" {
     vpc_id = aws_vpc.main.id
     
     route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main.id
     }
     
     tags = {
       Name = "${var.username}-terraform-public-rt"
       ManagedBy = "Terraform"
     }
   }
   
   # Route Table Association for Public Subnet
   resource "aws_route_table_association" "public" {
     subnet_id      = aws_subnet.public.id
     route_table_id = aws_route_table.public.id
   }
   
   # Outputs
   output "vpc_id" {
     value = aws_vpc.main.id
   }
   
   output "public_subnet_id" {
     value = aws_subnet.public.id
   }
   
   output "private_subnet_id" {
     value = aws_subnet.private.id
   }
HCL
   
   # Replace USERNAME with your actual username
   sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" vpc-main.tf
   ```

3. **Deploy VPC Infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   
   # Verify outputs
   terraform output
   ```

---

## Terraform vs CloudFormation Comparison

### Key Differences Observed:

| Aspect | Terraform | CloudFormation |
|--------|-----------|----------------|
| **Language** | HCL (HashiCorp Configuration Language) | JSON/YAML |
| **State Management** | Local/Remote state files | AWS-managed state |
| **Provider Support** | Multi-cloud (AWS, Azure, GCP, etc.) | AWS-only |
| **Resource Updates** | Plan before apply | Direct apply |
| **Learning Curve** | Moderate | Easy for AWS users |
| **Debugging** | Good error messages | AWS-specific errors |

### When to Use Each:
- **Terraform:** Multi-cloud deployments, complex workflows, team collaboration
- **CloudFormation:** AWS-only environments, tight AWS integration, AWS-native features

---

## Cleanup Instructions

**⚠️ Important:** Clean up all resources to avoid charges

### Step 1: Destroy Infrastructure
```bash
# Destroy VPC example
cd ~/terraform-lab/vpc-example
terraform destroy -auto-approve

# Destroy variables example
cd ~/terraform-lab/variables-example
terraform destroy -var-file="terraform.tfvars" -auto-approve

# Destroy basic example
cd ~/terraform-lab/basic-example
terraform destroy -auto-approve
```

### Step 2: Verify Cleanup
1. **Check AWS Console:**
   - Verify all EC2 instances are terminated
   - Verify all S3 buckets are deleted
   - Verify all VPCs (except default) are deleted
   - Verify all Security Groups (except default) are deleted

2. **Clean up lab files:**
   ```bash
   # Remove lab directory
   rm -rf ~/terraform-lab
   
   # Remove Terraform cache
   rm -rf ~/.terraform.d/
   ```

### Step 3: Terminate Lab Instance
1. **Terminate the Terraform instance:**
   - Go to EC2 Console
   - Select `USERNAME-terraform-instance`
   - **Actions** → **Instance State** → **Terminate instance**

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Terraform init fails**
- **Solution:** Check internet connectivity and AWS credentials
- **Verify:** `aws sts get-caller-identity` works

**Issue: Apply fails with permission errors**
- **Solution:** Verify IAM permissions for the AWS user/role
- **Check:** Ensure AdministratorAccess or specific service permissions

**Issue: Resources already exist**
- **Solution:** Use different names or destroy existing resources
- **Check:** AWS Console for conflicting resources

**Issue: State file conflicts**
- **Solution:** Remove `.terraform/` directory and run `terraform init` again
- **Note:** Be careful with state files in production

**Issue: Variable validation fails**
- **Solution:** Check variable types and validation rules
- **Verify:** Use `terraform validate` to check syntax

---

## Key Concepts Learned

1. **Infrastructure as Code Benefits:**
   - Version control for infrastructure
   - Repeatable deployments
   - Disaster recovery capabilities
   - Documentation through code

2. **Terraform Workflow:**
   - Write configuration files
   - Initialize working directory
   - Plan changes
   - Apply configuration
   - Manage state

3. **Best Practices:**
   - Use variables for flexibility
   - Implement proper tagging
   - Use modules for reusability
   - Version control configuration files
   - Implement remote state management

4. **State Management:**
   - Local vs remote state
   - State locking
   - State backup and recovery

---

## Validation Checklist

- [ ] Successfully installed Terraform on EC2 instance
- [ ] Created basic infrastructure using Terraform configuration
- [ ] Implemented variables and outputs effectively
- [ ] Deployed VPC infrastructure using Terraform
- [ ] Understood differences between Terraform and CloudFormation
- [ ] Successfully destroyed all created resources
- [ ] Cleaned up lab environment completely

---

## Next Steps

- **Production Usage:** Implement remote state storage (S3 + DynamoDB)
- **Advanced Features:** Explore Terraform modules and workspaces
- **CI/CD Integration:** Integrate Terraform with pipeline tools
- **Multi-Cloud:** Explore other cloud providers with Terraform

---

**Lab Duration:** 45 minutes  
**Difficulty:** Advanced  
**Prerequisites:** Basic understanding of AWS services, configuration files

EOF

    # Create lab progress tracking
    cat > lab-progress.md << 'EOF'
# Lab 12 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Terraform Installation and Setup
- [ ] Launched EC2 instance: `USERNAME-terraform-instance` (with your username)
- [ ] Connected to instance successfully
- [ ] Installed Terraform successfully
- [ ] Configured AWS CLI with proper credentials
- [ ] Verified setup with `terraform version` and `aws sts get-caller-identity`
- [ ] Created lab directory structure

### Task 2: Basic Terraform Configuration
- [ ] Created main.tf with basic AWS resources
- [ ] Replaced all USERNAME placeholders with actual username
- [ ] Successfully ran `terraform init`
- [ ] Successfully ran `terraform validate`
- [ ] Successfully ran `terraform plan`
- [ ] Successfully ran `terraform apply`
- [ ] Verified resources in AWS Console (S3 bucket, EC2 instance, Security Group)
- [ ] Tested web server functionality

### Task 3: Variables and Outputs
- [ ] Created variables.tf with input variables
- [ ] Created outputs.tf with useful outputs
- [ ] Created main.tf using variables
- [ ] Created user_data.sh script with templating
- [ ] Created terraform.tfvars file with values
- [ ] Successfully deployed with variables
- [ ] Tested all outputs work correctly
- [ ] Modified configuration and redeployed
- [ ] Verified changes applied correctly

### Advanced Exercise: VPC Creation
- [ ] Created comprehensive VPC configuration
- [ ] Deployed VPC infrastructure with Terraform
- [ ] Verified VPC, subnets, and routing created correctly
- [ ] Understood resource dependencies and relationships

### Cleanup
- [ ] Destroyed all VPC example resources
- [ ] Destroyed all variables example resources
- [ ] Destroyed all basic example resources
- [ ] Verified cleanup in AWS Console
- [ ] Terminated lab EC2 instance
- [ ] Removed all lab files

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Terraform Instance: ________________-terraform-instance
- Security Group: ________________-terraform-sg
- S3 Bucket: ________________-terraform-lab-bucket-xxxxxxxx
- Basic Instance: ________________-terraform-instance
- VPC: ________________-terraform-vpc

**Key Commands Used:**
- terraform init: ________________
- terraform plan: ________________
- terraform apply: ________________
- terraform destroy: ________________

**Terraform Outputs Tested:**
- instance_public_ip: ________________
- website_url: ________________
- vpc_id: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights About IaC:**


**Terraform vs CloudFormation Observations:**


**Time Completed:** ________________

EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
# Lab 12 Files

This directory contains all files needed for Lab 12: Infrastructure as Code with Terraform.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Lab Overview

This lab focuses on:
- Infrastructure as Code (IaC) principles and benefits
- Terraform installation and configuration
- Writing Terraform configuration files for AWS resources
- Using variables, outputs, and best practices
- Comparing Terraform with AWS CloudFormation
- Implementing proper cleanup and state management

## Key Learning Points

1. **IaC Benefits:** Version control, repeatability, documentation through code
2. **Terraform Workflow:** init → plan → apply → destroy
3. **Configuration Management:** Variables, outputs, and data sources
4. **Best Practices:** Proper tagging, modular design, state management
5. **Multi-Cloud Capability:** Understanding Terraform's cloud-agnostic approach

## Directory Structure Created During Lab

```
~/terraform-lab/
├── basic-example/
│   └── main.tf
├── variables-example/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user_data.sh
│   ├── terraform.tfvars
│   └── dev.tfvars
└── vpc-example/
    └── vpc-main.tf
```

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Follow cleanup instructions carefully to remove all resources
5. Document your observations about IaC benefits and Terraform vs CloudFormation

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab demonstrates Infrastructure as Code principles practically
- Terraform state management is crucial for team environments
- Always run `terraform plan` before `terraform apply` in production
- Keep configuration files in version control for real projects

## Skills Developed

- Infrastructure as Code implementation
- Terraform configuration and deployment
- AWS resource management through code
- Variable and output usage
- State management understanding
- Best practices for infrastructure automation

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 12 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with comprehensive instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ Documentation files${NC}"
    
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. cd $LAB_DIR"
    echo "2. cat README.md  # Read complete lab instructions"
    echo "3. Replace USERNAME with your assigned username throughout the lab"
    echo "4. Follow the step-by-step procedures"
    echo "5. Use lab-progress.md to track completion"
    
    echo ""
    echo -e "${BLUE}Lab Duration: 45 minutes${NC}"
    echo -e "${BLUE}Difficulty: Advanced${NC}"
    echo -e "${BLUE}Focus: Infrastructure as Code with Terraform${NC}"
    echo ""
    echo -e "${YELLOW}Key Topics:${NC}"
    echo "• Infrastructure as Code principles and benefits"
    echo "• Terraform installation and configuration"
    echo "• Writing and deploying Terraform configurations"
    echo "• Variables, outputs, and best practices"
    echo "• Terraform vs CloudFormation comparison"
    echo "• State management and cleanup procedures"
}

# Run main function
main "$@"