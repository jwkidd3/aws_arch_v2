# Lab 12: Infrastructure as Code with Terraform

**Duration:** 30 minutes  
**Objective:** Learn Infrastructure as Code principles using Terraform to deploy and manage AWS resources programmatically.

## Prerequisites
- Access to AWS Cloud9 environment
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all Terraform configuration files.

## Learning Outcomes
After completing this lab, you will be able to:
- Understand Infrastructure as Code (IaC) principles
- Write basic Terraform configuration files
- Deploy and destroy AWS resources with Terraform
- Use Terraform variables and outputs

---

## Task 1: Basic Terraform Configuration (15 minutes)

### Step 1: Setup in Cloud9
1. **Open Cloud9 Environment:**
   - Navigate to AWS Cloud9 in the console
   - Open your existing Cloud9 environment

2. **Verify Terraform and Navigate to Lab:**
```bash
# Check Terraform version (pre-installed in Cloud9)
terraform version

# Navigate to lab directory
cd lab12-terraform-iac/terraform-configs/basic

# List the provided files
ls -la
```

### Step 2: Review and Update Configuration
1. **Examine the provided Terraform files:**
   - `main.tf` - Main infrastructure configuration
   - `outputs.tf` - Output definitions

2. **Update the configuration with your username:**
```bash
# Replace USERNAME with your actual username (e.g., user1)
sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" *.tf
```

3. **Review the configuration:**
```bash
# Look at the main configuration
cat main.tf

# Look at the outputs
cat outputs.tf
```

### Step 3: Deploy Infrastructure
1. **Initialize and Apply:**
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
# Type 'yes' when prompted
```

2. **Verify Deployment:**
```bash
# Check outputs
terraform output

# Test web server
curl $(terraform output -raw website_url)
```

3. **Verify in AWS Console:**
   - Check EC2 Instances for your new instance
   - Check S3 for your new bucket
   - Check Security Groups for your new security group

---

## Task 2: Working with Variables (10 minutes)

### Step 1: Navigate to Variables Example
1. **Change to variables directory:**
```bash
cd ../variables

# List the provided files
ls -la
```

2. **Review the files:**
   - `main.tf` - Infrastructure using variables
   - `variables.tf` - Variable definitions
   - `outputs.tf` - Output definitions
   - `terraform.tfvars` - Variable values

### Step 2: Update Configuration
1. **Update with your username:**
```bash
# Replace USERNAME with your actual username
sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" *.tf *.tfvars
```

2. **Review the variable configuration:**
```bash
# Look at variable definitions
cat variables.tf

# Look at variable values
cat terraform.tfvars
```

### Step 3: Deploy with Variables
1. **Initialize and deploy:**
```bash
# Initialize Terraform
terraform init

# Plan with variables
terraform plan -var-file="terraform.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars"
```

2. **Test outputs:**
```bash
# Check all outputs
terraform output

# Check resource summary
terraform output resource_summary
```

---

## Task 3: Quick VPC Example (5 minutes)

### Step 1: VPC Configuration
1. **Navigate to VPC example:**
```bash
cd ../vpc

# List files
ls -la
```

2. **Update and deploy:**
```bash
# Update with your username
sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" *.tf

# Initialize and apply
terraform init
terraform plan
terraform apply

# Check VPC outputs
terraform output
```

---

## Cleanup Instructions

**⚠️ Important:** Clean up all resources to avoid charges

### Step 1: Destroy VPC Resources
```bash
cd terraform-configs/vpc
terraform destroy
# Type 'yes' when prompted
```

### Step 2: Destroy Variables Example
```bash
cd ../variables
terraform destroy
# Type 'yes' when prompted
```

### Step 3: Destroy Basic Example
```bash
cd ../basic
terraform destroy
# Type 'yes' when prompted
```

### Step 4: Verify Cleanup
Check AWS Console to ensure all resources are deleted:
- EC2 Instances
- S3 Buckets
- Security Groups
- VPC Resources

---

## Key Concepts Learned

1. **Infrastructure as Code Benefits:**
   - Version control for infrastructure
   - Repeatable deployments
   - Consistent environments

2. **Terraform Workflow:**
   - `terraform init` - Initialize working directory
   - `terraform plan` - Preview changes
   - `terraform apply` - Apply changes
   - `terraform destroy` - Remove resources

3. **Terraform Features:**
   - Variables for flexibility
   - Outputs for information sharing
   - Data sources for existing resources
   - Resource dependencies

4. **Best Practices:**
   - Use variables for reusability
   - Tag all resources consistently
   - Always run plan before apply
   - Clean up resources when done

---

## Troubleshooting

### Common Issues

**Problem:** Resource naming conflicts  
**Solution:** Ensure USERNAME is replaced with your actual username in all files

**Problem:** Permission errors  
**Solution:** Verify Cloud9 has proper IAM permissions

**Problem:** State file issues  
**Solution:** Delete `.terraform` directory and run `terraform init`

**Problem:** Variable not found errors  
**Solution:** Ensure you're using `-var-file="terraform.tfvars"` when running plan/apply

---

## Validation Checklist

- [ ] Successfully created basic infrastructure with Terraform
- [ ] Used variables to make configuration flexible
- [ ] Created VPC resources with Terraform
- [ ] Tested all outputs and functionality
- [ ] Successfully destroyed all resources

---

**Lab Duration:** 30 minutes  
**Difficulty:** Intermediate  
**Focus:** Infrastructure as Code fundamentals with Terraform

