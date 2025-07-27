# Lab 8 Files

This directory contains all files needed for Lab 8: Application Load Balancer Setup.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **terraform-examples.tf** - Terraform code examples for ALB
- **cloudwatch-monitoring.md** - CloudWatch monitoring guide
- **FILES.md** - This file, describing all lab files

## Lab Overview

This lab focuses on:
- Application Load Balancer configuration and management
- Target group creation and health check configuration
- Path-based routing and listener rule management
- High availability and fault tolerance implementation
- Performance monitoring and optimization

## Key Learning Points

1. **Load Balancer Architecture:** Understanding ALB vs NLB, layer 7 features
2. **Target Management:** Health checks, registration, and monitoring
3. **Routing Logic:** Path-based routing, host-based routing, rule priorities
4. **High Availability:** Multi-AZ deployment, automatic failover
5. **Security Integration:** Security groups, SSL termination, WAF integration

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Follow cleanup instructions carefully to remove all resources
5. Use **cloudwatch-monitoring.md** for advanced monitoring setup

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab builds on Lab 4 (VPC Networking Setup)
- Requires multiple EC2 instances across different AZs
- Focus on understanding health check mechanics and routing rules
- Monitor costs and clean up resources immediately after completion

