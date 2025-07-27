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

