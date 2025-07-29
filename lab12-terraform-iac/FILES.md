# Lab 12 Files

This directory contains all files needed for Lab 12: Infrastructure as Code with Terraform.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist  
- **FILES.md** - This file, describing all lab files

## Terraform Configuration Directories

### terraform-configs/basic/
- **main.tf** - Basic infrastructure configuration (S3, EC2, Security Group)
- **outputs.tf** - Output definitions for basic resources

### terraform-configs/variables/
- **main.tf** - Infrastructure configuration using variables
- **variables.tf** - Variable definitions and defaults
- **outputs.tf** - Output definitions with variable usage
- **terraform.tfvars** - Variable values for deployment

### terraform-configs/vpc/
- **main.tf** - VPC infrastructure configuration
- **outputs.tf** - VPC resource outputs

## Lab Overview

This lab focuses on:
- Infrastructure as Code (IaC) principles
- Basic Terraform usage in Cloud9
- Writing and organizing Terraform configuration files
- Using variables and outputs
- Resource lifecycle management

## Directory Structure

```
lab12-terraform-iac/
├── README.md
├── lab-progress.md
├── FILES.md
└── terraform-configs/
    ├── basic/
    │   ├── main.tf
    │   └── outputs.tf
    ├── variables/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars
    └── vpc/
        ├── main.tf
        └── outputs.tf
```

## Key Learning Points

1. **IaC Benefits:** Repeatable, version-controlled infrastructure
2. **Terraform Workflow:** init → plan → apply → destroy  
3. **Variables:** Making configurations flexible and reusable
4. **Outputs:** Sharing information between resources and users
5. **Resource Management:** Creating and destroying infrastructure programmatically

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Navigate to each terraform-configs subdirectory for hands-on work
4. Remember to replace USERNAME with your assigned username in all .tf files
5. Follow cleanup instructions to avoid charges

## Important Notes

- This lab uses Cloud9 which has Terraform pre-installed
- All resource names must include your username prefix
- Always run `terraform plan` before `terraform apply`
- Clean up all resources with `terraform destroy`
- Each subdirectory is a separate Terraform workspace

## Skills Developed

- Basic Infrastructure as Code concepts
- Terraform workflow and commands
- AWS resource creation through code
- Variable usage for flexible configurations
- Resource cleanup and lifecycle management
- Terraform project organization

