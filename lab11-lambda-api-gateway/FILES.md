# Lab 11 Files

This directory contains all files needed for Lab 11: Lambda Functions & API Gateway.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **terraform-example.tf** - Advanced Terraform configuration example
- **test-api.py** - Python script for testing API endpoints
- **FILES.md** - This file, describing all lab files

## Lambda Functions Directory

- **lambda-functions/create_task.py** - Template for create task Lambda function
- **lambda-functions/get_tasks.py** - Template for get/list tasks Lambda function
- **lambda-functions/update_task.py** - Template for update task Lambda function
- **lambda-functions/delete_task.py** - Template for delete task Lambda function

## Lab Overview

This lab focuses on:
- Building serverless applications with AWS Lambda
- Creating RESTful APIs with API Gateway
- Integrating Lambda functions with DynamoDB
- Implementing proper IAM security
- Testing complete serverless workflows

## Key Learning Points

1. **Serverless Architecture:** Understanding event-driven computing and auto-scaling
2. **API Design:** RESTful API principles and HTTP methods
3. **Lambda Integration:** Event structure, error handling, and best practices
4. **DynamoDB Operations:** NoSQL data modeling and CRUD operations
5. **Security:** IAM roles and service-to-service authentication

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Follow cleanup instructions carefully to remove all resources
5. Use **test-api.py** for additional API testing (optional)

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab integrates multiple AWS services in a serverless architecture
- Focus on understanding the event flow between API Gateway, Lambda, and DynamoDB
- Pay attention to IAM permissions and security best practices
- Test thoroughly before cleanup to ensure understanding

## Architecture

```
Client Request → API Gateway → Lambda Function → DynamoDB
                     ↓
                Response ← Lambda Response ← Data Storage
```

This lab demonstrates modern serverless application patterns and prepares you for building production-ready APIs.

