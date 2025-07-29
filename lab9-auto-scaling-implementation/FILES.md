# Lab 9 Files

This directory contains all files needed for Lab 9: Auto Scaling Implementation.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **terraform-examples.tf** - Terraform code examples (advanced)
- **cloudwatch-monitoring.md** - CloudWatch monitoring guide
- **FILES.md** - This file, describing all lab files

## Lab Overview

This lab focuses on:
- Creating launch templates with comprehensive user data scripts
- Configuring Auto Scaling groups with proper capacity management
- Setting up target tracking scaling policies based on CloudWatch metrics
- Testing automatic scaling behavior under load
- Integrating Auto Scaling with Application Load Balancers
- Monitoring scaling activities and cost implications

## Key Learning Points

1. **Launch Templates:** Modern approach to instance configuration with versioning
2. **Auto Scaling Groups:** Dynamic capacity management across availability zones
3. **Scaling Policies:** Target tracking vs step scaling strategies
4. **Load Balancer Integration:** Automatic registration and health checks
5. **CloudWatch Monitoring:** Metrics collection and alarm-based scaling
6. **Cost Optimization:** Understanding scaling efficiency and resource utilization

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Follow cleanup instructions carefully to remove all resources
5. Use **cloudwatch-monitoring.md** for advanced monitoring setup

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab builds on previous VPC and EC2 knowledge
- Focus on understanding scaling triggers and cooldown periods
- Monitor CloudWatch metrics throughout the exercise
- Pay attention to cost implications of scaling decisions

## Auto Scaling Architecture

```
Internet Gateway
     |
Application Load Balancer
     |
Target Group
     |
Auto Scaling Group
 /       |        \
Instance Instance Instance
(Multi-AZ deployment)
```

## Scaling Policy Logic

```
CPU > 50% for 5 minutes → Scale Out
CPU < 50% for 5 minutes → Scale In
Cooldown: 300 seconds
Warmup: 300 seconds
```

This lab demonstrates enterprise-grade auto scaling patterns and prepares you for production workloads.

