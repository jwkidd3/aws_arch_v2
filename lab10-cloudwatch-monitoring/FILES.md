# Lab 10 Files

This directory contains all files needed for Lab 10: CloudWatch Monitoring & Alerts.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Scripts Directory

- **generate-load.sh** - CPU load generation for alarm testing
- **memory-test.sh** - Memory load generation for custom metrics
- **cloudwatch-agent-config.json** - CloudWatch agent configuration template
- **generate-logs.sh** - Log generation script for CloudWatch Logs testing
- **send-custom-metrics.sh** - Custom metrics publishing script
- **insights-queries.txt** - Sample CloudWatch Insights queries

## Lab Overview

This lab focuses on:
- Comprehensive CloudWatch monitoring setup
- Custom dashboard creation and management
- CloudWatch alarms with SNS notifications
- CloudWatch Logs configuration and analysis
- Custom metrics and application monitoring
- Performance testing and alarm validation

## Key Learning Points

1. **Monitoring Strategy:** Understanding what metrics to monitor and why
2. **Dashboard Design:** Creating effective operational dashboards
3. **Alerting Best Practices:** Setting appropriate thresholds and notification strategies
4. **Log Management:** Centralized logging and analysis techniques
5. **Custom Metrics:** Publishing application-specific metrics
6. **Cost Optimization:** Understanding CloudWatch pricing and optimization strategies

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Use scripts in the **scripts/** directory for testing and validation
5. Follow cleanup instructions carefully to remove all resources

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab builds on previous labs and requires existing infrastructure
- Monitor costs as CloudWatch detailed monitoring incurs charges
- Test alarm functionality thoroughly before concluding the lab
- Document your observations for future reference

## Prerequisites

- Completed previous labs (EC2, VPC, security groups)
- Access to AWS Management Console
- Email access for SNS notifications
- Basic understanding of system monitoring concepts

## Expected Outcomes

After completing this lab, you will have:
- A comprehensive CloudWatch monitoring setup
- Functional alarms with email notifications
- Custom dashboards for operational visibility
- CloudWatch Logs configuration for application monitoring
- Understanding of CloudWatch best practices and cost considerations

