# Lab 12 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Basic Terraform Configuration (15 minutes)
- [ ] Opened Cloud9 environment
- [ ] Verified Terraform with `terraform version`
- [ ] Navigated to terraform-configs/basic directory
- [ ] Reviewed main.tf and outputs.tf files
- [ ] Replaced USERNAME placeholders with actual username
- [ ] Successfully ran `terraform init`
- [ ] Successfully ran `terraform plan`
- [ ] Successfully ran `terraform apply`
- [ ] Verified resources in AWS Console
- [ ] Tested website URL from output

### Task 2: Working with Variables (10 minutes)
- [ ] Navigated to terraform-configs/variables directory
- [ ] Reviewed variables.tf, main.tf, outputs.tf, and terraform.tfvars files
- [ ] Replaced USERNAME placeholders in all files
- [ ] Successfully ran `terraform init`
- [ ] Successfully ran `terraform plan -var-file="terraform.tfvars"`
- [ ] Successfully ran `terraform apply -var-file="terraform.tfvars"`
- [ ] Tested all outputs including resource_summary
- [ ] Verified variable values in deployed resources

### Task 3: Quick VPC Example (5 minutes)
- [ ] Navigated to terraform-configs/vpc directory
- [ ] Reviewed main.tf and outputs.tf files
- [ ] Replaced USERNAME placeholders
- [ ] Successfully ran `terraform init`
- [ ] Successfully ran `terraform plan`
- [ ] Successfully ran `terraform apply`
- [ ] Verified VPC creation in AWS Console
- [ ] Tested VPC outputs

### Cleanup
- [ ] Successfully destroyed VPC resources
- [ ] Successfully destroyed variables example resources
- [ ] Successfully destroyed basic example resources
- [ ] Confirmed all resources deleted in AWS Console
- [ ] No unexpected charges incurred

## Notes

**Your Username:** ________________

**Key Resources Created:**
- S3 Bucket: ________________
- EC2 Instance: ________________
- Security Group: ________________
- VPC: ________________

**Terraform Commands Used:**
- terraform init: ✓ / ✗
- terraform plan: ✓ / ✗
- terraform apply: ✓ / ✗
- terraform destroy: ✓ / ✗

**Outputs Tested:**
- instance_public_ip: ________________
- website_url: ________________
- s3_bucket_name: ________________
- vpc_id: ________________

**Issues Encountered:**


**Key Insights:**


**Time Completed:** ________________

