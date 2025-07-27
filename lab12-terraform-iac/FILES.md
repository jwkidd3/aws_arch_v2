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

