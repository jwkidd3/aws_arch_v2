#!/bin/bash

# Lab 11 Setup Script: Lambda Functions & API Gateway
# AWS Architecting Course - Day 3, Session 3
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
    print_header "AWS Architecting Course - Lab 11 Setup"
    print_status "Setting up Lambda Functions & API Gateway Lab"
    
    # Create lab directory structure
    LAB_DIR="lab11-lambda-api-gateway"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
# Lab 11: Lambda Functions & API Gateway

**Duration:** 45 minutes  
**Objective:** Build a complete serverless API using AWS Lambda, API Gateway, and DynamoDB for data persistence.

## Prerequisites
- Completion of previous labs (especially DynamoDB concepts)
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and configure AWS Lambda functions
- Set up API Gateway with REST endpoints
- Integrate Lambda with DynamoDB for data persistence
- Implement proper IAM roles for serverless applications
- Test complete serverless API workflows
- Understand event-driven architecture patterns

---

## Architecture Overview

You'll build a serverless task management API with the following components:
- **API Gateway**: RESTful API endpoints
- **Lambda Functions**: Business logic for CRUD operations
- **DynamoDB**: NoSQL database for task storage
- **IAM Roles**: Secure service-to-service communication

---

## Task 1: DynamoDB Table Setup (10 minutes)

### Step 1: Create DynamoDB Table
1. **Navigate to DynamoDB:**
   - In the AWS Management Console, search for "DynamoDB"
   - Click on **DynamoDB** to open the dashboard

2. **Create Table:**
   - Click **Create table**
   - **Table name:** `USERNAME-tasks` ⚠️ **Replace USERNAME with your assigned username**
   - **Partition key:** `taskId` (String)
   - Leave **Sort key** empty
   - **Table settings:** Use default settings
   - Click **Create table**

3. **Verify Table Creation:**
   - Wait for table status to show "Active"
   - Note the table ARN for later use

### Step 2: Test Data (Optional)
You can add sample data later through the Lambda functions we'll create.

---

## Task 2: IAM Role for Lambda (10 minutes)

### Step 1: Create Lambda Execution Role
1. **Navigate to IAM:**
   - Search for "IAM" in the AWS console
   - Click **Roles** in the left navigation

2. **Create Role:**
   - Click **Create role**
   - **Trusted entity type:** AWS service
   - **Service:** Lambda
   - Click **Next**

3. **Attach Policies:**
   - Search and select: `AWSLambdaBasicExecutionRole`
   - Search and select: `AmazonDynamoDBFullAccess`
   - Click **Next**

4. **Name and Create:**
   - **Role name:** `USERNAME-lambda-dynamodb-role` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Role for Lambda to access DynamoDB and CloudWatch`
   - Click **Create role**

---

## Task 3: Lambda Functions Creation (15 minutes)

### Step 1: Create Task Creation Function
1. **Navigate to Lambda:**
   - Search for "Lambda" in the AWS console
   - Click **Create function**

2. **Function Configuration:**
   - Choose **Author from scratch**
   - **Function name:** `USERNAME-create-task` ⚠️ **Replace USERNAME with your assigned username**
   - **Runtime:** Python 3.11
   - **Architecture:** x86_64
   - **Execution role:** Use existing role: `USERNAME-lambda-dynamodb-role`
   - Click **Create function**

3. **Function Code:**
   ```python
   import json
   import boto3
   import uuid
   from datetime import datetime
   from decimal import Decimal

   # Initialize DynamoDB resource
   dynamodb = boto3.resource('dynamodb')
   table = dynamodb.Table('USERNAME-tasks')  # Replace USERNAME with your username

   def lambda_handler(event, context):
       try:
           # Parse request body
           if 'body' in event:
               body = json.loads(event['body'])
           else:
               body = event
           
           # Generate unique task ID
           task_id = str(uuid.uuid4())
           
           # Create task item
           task = {
               'taskId': task_id,
               'title': body.get('title', 'Untitled Task'),
               'description': body.get('description', ''),
               'status': body.get('status', 'pending'),
               'priority': body.get('priority', 'medium'),
               'createdAt': datetime.now().isoformat(),
               'updatedAt': datetime.now().isoformat()
           }
           
           # Save to DynamoDB
           table.put_item(Item=task)
           
           return {
               'statusCode': 201,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'message': 'Task created successfully',
                   'taskId': task_id,
                   'task': task
               })
           }
           
       except Exception as e:
           print(f"Error: {str(e)}")
           return {
               'statusCode': 500,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'error': 'Internal server error',
                   'message': str(e)
               })
           }
   ```

4. **Deploy and Test:**
   - Click **Deploy**
   - Click **Test** tab
   - **Event name:** `test-create-task`
   - **Event JSON:**
   ```json
   {
     "title": "Learn AWS Lambda",
     "description": "Complete serverless lab exercise",
     "status": "in-progress",
     "priority": "high"
   }
   ```
   - Click **Test**
   - Verify successful execution

### Step 2: Create Task Retrieval Function
1. **Create New Function:**
   - **Function name:** `USERNAME-get-tasks` ⚠️ **Replace USERNAME with your assigned username**
   - Use same runtime and role as previous function

2. **Function Code:**
   ```python
   import json
   import boto3
   from boto3.dynamodb.conditions import Key
   from decimal import Decimal

   # Initialize DynamoDB resource
   dynamodb = boto3.resource('dynamodb')
   table = dynamodb.Table('USERNAME-tasks')  # Replace USERNAME with your username

   class DecimalEncoder(json.JSONEncoder):
       def default(self, obj):
           if isinstance(obj, Decimal):
               return float(obj)
           return super(DecimalEncoder, self).default(obj)

   def lambda_handler(event, context):
       try:
           # Check if specific task ID is requested
           if 'pathParameters' in event and event['pathParameters'] and 'taskId' in event['pathParameters']:
               task_id = event['pathParameters']['taskId']
               
               # Get specific task
               response = table.get_item(Key={'taskId': task_id})
               
               if 'Item' in response:
                   return {
                       'statusCode': 200,
                       'headers': {
                           'Content-Type': 'application/json',
                           'Access-Control-Allow-Origin': '*'
                       },
                       'body': json.dumps(response['Item'], cls=DecimalEncoder)
                   }
               else:
                   return {
                       'statusCode': 404,
                       'headers': {
                           'Content-Type': 'application/json',
                           'Access-Control-Allow-Origin': '*'
                       },
                       'body': json.dumps({'error': 'Task not found'})
                   }
           else:
               # Get all tasks
               response = table.scan()
               
               return {
                   'statusCode': 200,
                   'headers': {
                       'Content-Type': 'application/json',
                       'Access-Control-Allow-Origin': '*'
                   },
                   'body': json.dumps({
                       'tasks': response['Items'],
                       'count': len(response['Items'])
                   }, cls=DecimalEncoder)
               }
               
       except Exception as e:
           print(f"Error: {str(e)}")
           return {
               'statusCode': 500,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'error': 'Internal server error',
                   'message': str(e)
               })
           }
   ```

3. **Deploy and Test:**
   - Click **Deploy**
   - Test with empty event `{}`

### Step 3: Create Task Update Function
1. **Create New Function:**
   - **Function name:** `USERNAME-update-task` ⚠️ **Replace USERNAME with your assigned username**
   - Use same runtime and role

2. **Function Code:**
   ```python
   import json
   import boto3
   from datetime import datetime
   from decimal import Decimal

   # Initialize DynamoDB resource
   dynamodb = boto3.resource('dynamodb')
   table = dynamodb.Table('USERNAME-tasks')  # Replace USERNAME with your username

   class DecimalEncoder(json.JSONEncoder):
       def default(self, obj):
           if isinstance(obj, Decimal):
               return float(obj)
           return super(DecimalEncoder, self).default(obj)

   def lambda_handler(event, context):
       try:
           # Get task ID from path parameters
           if 'pathParameters' not in event or not event['pathParameters'] or 'taskId' not in event['pathParameters']:
               return {
                   'statusCode': 400,
                   'headers': {
                       'Content-Type': 'application/json',
                       'Access-Control-Allow-Origin': '*'
                   },
                   'body': json.dumps({'error': 'Task ID is required'})
               }
           
           task_id = event['pathParameters']['taskId']
           body = json.loads(event['body'])
           
           # Build update expression
           update_expression = "SET updatedAt = :updatedAt"
           expression_values = {':updatedAt': datetime.now().isoformat()}
           
           if 'title' in body:
               update_expression += ", title = :title"
               expression_values[':title'] = body['title']
           
           if 'description' in body:
               update_expression += ", description = :description"
               expression_values[':description'] = body['description']
           
           if 'status' in body:
               update_expression += ", #status = :status"
               expression_values[':status'] = body['status']
           
           if 'priority' in body:
               update_expression += ", priority = :priority"
               expression_values[':priority'] = body['priority']
           
           # Update item
           response = table.update_item(
               Key={'taskId': task_id},
               UpdateExpression=update_expression,
               ExpressionAttributeValues=expression_values,
               ExpressionAttributeNames={'#status': 'status'} if 'status' in body else None,
               ReturnValues='ALL_NEW'
           )
           
           return {
               'statusCode': 200,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'message': 'Task updated successfully',
                   'task': response['Attributes']
               }, cls=DecimalEncoder)
           }
           
       except Exception as e:
           print(f"Error: {str(e)}")
           return {
               'statusCode': 500,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'error': 'Internal server error',
                   'message': str(e)
               })
           }
   ```

3. **Deploy and Test:**
   - Click **Deploy**
   - Test with path parameters and body

### Step 4: Create Task Deletion Function
1. **Create New Function:**
   - **Function name:** `USERNAME-delete-task` ⚠️ **Replace USERNAME with your assigned username**
   - Use same runtime and role

2. **Function Code:**
   ```python
   import json
   import boto3

   # Initialize DynamoDB resource
   dynamodb = boto3.resource('dynamodb')
   table = dynamodb.Table('USERNAME-tasks')  # Replace USERNAME with your username

   def lambda_handler(event, context):
       try:
           # Get task ID from path parameters
           if 'pathParameters' not in event or not event['pathParameters'] or 'taskId' not in event['pathParameters']:
               return {
                   'statusCode': 400,
                   'headers': {
                       'Content-Type': 'application/json',
                       'Access-Control-Allow-Origin': '*'
                   },
                   'body': json.dumps({'error': 'Task ID is required'})
               }
           
           task_id = event['pathParameters']['taskId']
           
           # Delete item
           table.delete_item(Key={'taskId': task_id})
           
           return {
               'statusCode': 200,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'message': 'Task deleted successfully',
                   'taskId': task_id
               })
           }
           
       except Exception as e:
           print(f"Error: {str(e)}")
           return {
               'statusCode': 500,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'error': 'Internal server error',
                   'message': str(e)
               })
           }
   ```

3. **Deploy the function**

---

## Task 4: API Gateway Setup (10 minutes)

### Step 1: Create REST API
1. **Navigate to API Gateway:**
   - Search for "API Gateway" in AWS console
   - Click **Create API**
   - Choose **REST API** (not REST API Private)
   - Click **Build**

2. **API Configuration:**
   - **API name:** `USERNAME-tasks-api` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `RESTful API for task management`
   - **Endpoint Type:** Regional
   - Click **Create API**

### Step 2: Create Resources and Methods
1. **Create Tasks Resource:**
   - Click **Actions** → **Create Resource**
   - **Resource Name:** `tasks`
   - **Resource Path:** `/tasks`
   - **Enable API Gateway CORS:** ✓ Check this
   - Click **Create Resource**

2. **Create Task Item Resource:**
   - Select `/tasks` resource
   - Click **Actions** → **Create Resource**
   - **Resource Name:** `task`
   - **Resource Path:** `/{taskId}`
   - **Enable API Gateway CORS:** ✓ Check this
   - Click **Create Resource**

### Step 3: Configure Methods
1. **POST Method for Creating Tasks:**
   - Select `/tasks` resource
   - Click **Actions** → **Create Method**
   - Select **POST** from dropdown
   - Click the checkmark
   - **Integration type:** Lambda Function
   - **Lambda Region:** us-east-1
   - **Lambda Function:** `USERNAME-create-task` ⚠️ **Use your username**
   - Click **Save**
   - Click **OK** to grant permission

2. **GET Method for Listing Tasks:**
   - Select `/tasks` resource
   - Click **Actions** → **Create Method**
   - Select **GET** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-get-tasks` ⚠️ **Use your username**
   - Click **Save**

3. **GET Method for Single Task:**
   - Select `/{taskId}` resource
   - Click **Actions** → **Create Method**
   - Select **GET** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-get-tasks` ⚠️ **Use your username**
   - Click **Save**

4. **PUT Method for Updating Tasks:**
   - Select `/{taskId}` resource
   - Click **Actions** → **Create Method**
   - Select **PUT** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-update-task` ⚠️ **Use your username**
   - Click **Save**

5. **DELETE Method for Deleting Tasks:**
   - Select `/{taskId}` resource
   - Click **Actions** → **Create Method**
   - Select **DELETE** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-delete-task` ⚠️ **Use your username**
   - Click **Save**

### Step 4: Deploy API
1. **Create Deployment:**
   - Click **Actions** → **Deploy API**
   - **Deployment stage:** [New Stage]
   - **Stage name:** `dev`
   - **Stage description:** `Development stage`
   - Click **Deploy**

2. **Note API URL:**
   - Copy the **Invoke URL** from the stage details
   - Format: `https://xxxxxxxx.execute-api.us-east-1.amazonaws.com/dev`

---

## Task 5: API Testing and Validation (10 minutes)

### Step 1: Test with AWS Console
1. **Test POST /tasks:**
   - In API Gateway, select POST method under `/tasks`
   - Click **TEST**
   - **Request Body:**
   ```json
   {
     "title": "Complete AWS Lab",
     "description": "Finish Lambda and API Gateway lab",
     "status": "in-progress",
     "priority": "high"
   }
   ```
   - Click **Test**
   - Verify 201 response

2. **Test GET /tasks:**
   - Select GET method under `/tasks`
   - Click **TEST**
   - Click **Test**
   - Verify 200 response with task list

### Step 2: Test with External Tools (Optional)
If you have access to curl or Postman:

```bash
# Create a task
curl -X POST https://YOUR_API_URL/dev/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "Testing API",
    "status": "pending",
    "priority": "medium"
  }'

# Get all tasks
curl https://YOUR_API_URL/dev/tasks

# Update a task (replace TASK_ID)
curl -X PUT https://YOUR_API_URL/dev/tasks/TASK_ID \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed"
  }'

# Delete a task (replace TASK_ID)
curl -X DELETE https://YOUR_API_URL/dev/tasks/TASK_ID
```

### Step 3: Verify DynamoDB Data
1. **Check DynamoDB Table:**
   - Go to DynamoDB console
   - Select your `USERNAME-tasks` table
   - Click **Explore table items**
   - Verify tasks are being stored correctly

---

## Advanced Exercise (Optional)

### Add Request Validation
1. **Create Model in API Gateway:**
   - Go to your API in API Gateway
   - Click **Models**
   - Click **Create**
   - **Model name:** `TaskModel`
   - **Content type:** `application/json`
   - **Model schema:**
   ```json
   {
     "$schema": "http://json-schema.org/draft-04/schema#",
     "title": "Task Schema",
     "type": "object",
     "properties": {
       "title": {
         "type": "string",
         "minLength": 1,
         "maxLength": 100
       },
       "description": {
         "type": "string",
         "maxLength": 500
       },
       "status": {
         "type": "string",
         "enum": ["pending", "in-progress", "completed"]
       },
       "priority": {
         "type": "string",
         "enum": ["low", "medium", "high"]
       }
     },
     "required": ["title"]
   }
   ```

2. **Apply Validation:**
   - Go to POST method under `/tasks`
   - Click **Method Request**
   - **Request Validator:** Validate body
   - **Request Body:** Add model for `application/json`

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Delete API Gateway
1. Go to API Gateway console
2. Select your API (`USERNAME-tasks-api`)
3. **Actions** → **Delete API**
4. Confirm deletion

### Step 2: Delete Lambda Functions
1. Go to Lambda console
2. Delete all four functions:
   - `USERNAME-create-task`
   - `USERNAME-get-tasks`
   - `USERNAME-update-task`
   - `USERNAME-delete-task`

### Step 3: Delete DynamoDB Table
1. Go to DynamoDB console
2. Select `USERNAME-tasks` table
3. **Delete** → Confirm deletion

### Step 4: Delete IAM Role
1. Go to IAM console
2. **Roles** → Select `USERNAME-lambda-dynamodb-role`
3. **Delete** → Confirm deletion

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Lambda function timeout**
- **Solution:** Increase timeout in function configuration (default is 3 seconds)
- **Check:** Function complexity and DynamoDB response times

**Issue: CORS errors in API Gateway**
- **Solution:** Enable CORS on resources and redeploy API
- **Verify:** CORS headers in Lambda responses

**Issue: DynamoDB permission denied**
- **Solution:** Verify IAM role has DynamoDB permissions
- **Check:** Role is attached to Lambda functions

**Issue: API Gateway 502 Bad Gateway**
- **Solution:** Check Lambda function logs in CloudWatch
- **Verify:** Function returns proper response format

**Issue: JSON parsing errors**
- **Solution:** Validate JSON format in requests
- **Check:** Content-Type headers

---

## Key Concepts Learned

1. **Serverless Architecture:**
   - Event-driven computing with Lambda
   - Pay-per-execution pricing model
   - Automatic scaling and high availability

2. **API Gateway Features:**
   - RESTful API design and implementation
   - Request/response transformation
   - Authentication and authorization options

3. **Lambda Integration Patterns:**
   - Proxy integration vs custom integration
   - Event structure and context objects
   - Error handling and logging

4. **DynamoDB Integration:**
   - NoSQL data modeling
   - CRUD operations with boto3
   - Performance considerations

5. **Security Best Practices:**
   - IAM roles for service-to-service communication
   - Least privilege principle
   - CORS configuration

---

## Validation Checklist

- [ ] Successfully created DynamoDB table with proper naming
- [ ] Created IAM role with appropriate permissions
- [ ] Deployed four Lambda functions with correct code
- [ ] Configured API Gateway with proper REST endpoints
- [ ] Tested all CRUD operations through API
- [ ] Verified data persistence in DynamoDB
- [ ] Cleaned up all resources properly

---

## Next Steps

- **Lab 12:** Infrastructure as Code with Terraform
- **Advanced Topics:** API Gateway authentication, Lambda layers, Step Functions
- **Real-world Applications:** Microservices architecture, event-driven systems

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Basic understanding of REST APIs, JSON, and AWS services

EOF

    # Create lab progress tracking
    cat > lab-progress.md << 'EOF'
# Lab 11 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: DynamoDB Table Setup
- [ ] Navigated to DynamoDB console
- [ ] Created table: `USERNAME-tasks` (with your username)
- [ ] Configured partition key: `taskId` (String)
- [ ] Verified table status is "Active"
- [ ] Noted table ARN for reference

### Task 2: IAM Role for Lambda
- [ ] Navigated to IAM console
- [ ] Created new role for Lambda service
- [ ] Attached `AWSLambdaBasicExecutionRole` policy
- [ ] Attached `AmazonDynamoDBFullAccess` policy
- [ ] Named role: `USERNAME-lambda-dynamodb-role` (with your username)
- [ ] Verified role creation successful

### Task 3: Lambda Functions Creation
- [ ] Created function: `USERNAME-create-task` (with your username)
- [ ] Deployed create task function code
- [ ] Tested create task function successfully
- [ ] Created function: `USERNAME-get-tasks` (with your username)
- [ ] Deployed get tasks function code
- [ ] Tested get tasks function successfully
- [ ] Created function: `USERNAME-update-task` (with your username)
- [ ] Deployed update task function code
- [ ] Created function: `USERNAME-delete-task` (with your username)
- [ ] Deployed delete task function code
- [ ] All functions use correct IAM role

### Task 4: API Gateway Setup
- [ ] Created REST API: `USERNAME-tasks-api` (with your username)
- [ ] Created `/tasks` resource with CORS enabled
- [ ] Created `/{taskId}` resource with CORS enabled
- [ ] Configured POST method on `/tasks` → `USERNAME-create-task`
- [ ] Configured GET method on `/tasks` → `USERNAME-get-tasks`
- [ ] Configured GET method on `/{taskId}` → `USERNAME-get-tasks`
- [ ] Configured PUT method on `/{taskId}` → `USERNAME-update-task`
- [ ] Configured DELETE method on `/{taskId}` → `USERNAME-delete-task`
- [ ] Deployed API to `dev` stage
- [ ] Noted API invoke URL

### Task 5: API Testing and Validation
- [ ] Tested POST /tasks through API Gateway console
- [ ] Tested GET /tasks through API Gateway console
- [ ] Verified successful responses (201, 200 status codes)
- [ ] Checked DynamoDB table for stored data
- [ ] Tested with external tools (optional)

### Advanced Exercise (Optional)
- [ ] Created request validation model
- [ ] Applied validation to API methods
- [ ] Tested validation behavior

### Cleanup
- [ ] Deleted API Gateway: `USERNAME-tasks-api`
- [ ] Deleted all four Lambda functions
- [ ] Deleted DynamoDB table: `USERNAME-tasks`
- [ ] Deleted IAM role: `USERNAME-lambda-dynamodb-role`
- [ ] Verified all resources removed

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- DynamoDB Table: ________________-tasks
- IAM Role: ________________-lambda-dynamodb-role
- Lambda Functions:
  - ________________-create-task
  - ________________-get-tasks
  - ________________-update-task
  - ________________-delete-task
- API Gateway: ________________-tasks-api

**API Details:**
- Invoke URL: ________________
- Stage: dev
- Resources: /tasks, /{taskId}

**Function ARNs:**
- Create Task: ________________
- Get Tasks: ________________
- Update Task: ________________
- Delete Task: ________________

**Test Results:**
- POST /tasks: ________________
- GET /tasks: ________________
- GET /{taskId}: ________________
- PUT /{taskId}: ________________
- DELETE /{taskId}: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights:**


**Time Completed:** ________________

EOF

    # Create sample Terraform configuration for advanced users
    cat > terraform-example.tf << 'EOF'
# Advanced: Terraform configuration for serverless infrastructure
# This is for reference only - not part of the main lab

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# DynamoDB Table
resource "aws_dynamodb_table" "tasks" {
  name           = "${var.username}-tasks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  tags = {
    Name = "${var.username}-tasks"
    Lab  = "11"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.username}-lambda-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

# Variables
variable "username" {
  description = "Username prefix for resources"
  type        = string
  default     = "user1"  # Replace with your username
}

# Outputs
output "dynamodb_table_name" {
  value = aws_dynamodb_table.tasks.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
EOF

    # Create Lambda function templates
    mkdir -p lambda-functions
    
    # Create task function template
    cat > lambda-functions/create_task.py << 'EOF'
import json
import boto3
import uuid
from datetime import datetime

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('USERNAME-tasks')  # Replace USERNAME with your username

def lambda_handler(event, context):
    try:
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Generate unique task ID
        task_id = str(uuid.uuid4())
        
        # Create task item
        task = {
            'taskId': task_id,
            'title': body.get('title', 'Untitled Task'),
            'description': body.get('description', ''),
            'status': body.get('status', 'pending'),
            'priority': body.get('priority', 'medium'),
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
        
        # Save to DynamoDB
        table.put_item(Item=task)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Task created successfully',
                'taskId': task_id,
                'task': task
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
EOF

    # Create API Gateway test script
    cat > test-api.py << 'EOF'
#!/usr/bin/env python3
"""
Test script for Lambda Functions & API Gateway Lab
Replace API_URL with your actual API Gateway URL
"""

import requests
import json
import sys

# Replace with your API Gateway URL
API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev"

def test_create_task():
    """Test creating a new task"""
    print("Testing POST /tasks...")
    
    task_data = {
        "title": "Test API Integration",
        "description": "Testing the complete serverless stack",
        "status": "in-progress",
        "priority": "high"
    }
    
    response = requests.post(f"{API_URL}/tasks", json=task_data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    
    if response.status_code == 201:
        return response.json().get('taskId')
    return None

def test_get_tasks():
    """Test getting all tasks"""
    print("\nTesting GET /tasks...")
    
    response = requests.get(f"{API_URL}/tasks")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

def test_update_task(task_id):
    """Test updating a task"""
    if not task_id:
        print("\nSkipping update test - no task ID available")
        return
    
    print(f"\nTesting PUT /tasks/{task_id}...")
    
    update_data = {
        "status": "completed",
        "description": "Updated via API test"
    }
    
    response = requests.put(f"{API_URL}/tasks/{task_id}", json=update_data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

def test_delete_task(task_id):
    """Test deleting a task"""
    if not task_id:
        print("\nSkipping delete test - no task ID available")
        return
    
    print(f"\nTesting DELETE /tasks/{task_id}...")
    
    response = requests.delete(f"{API_URL}/tasks/{task_id}")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

def main():
    if API_URL == "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev":
        print("Please update API_URL in the script with your actual API Gateway URL")
        sys.exit(1)
    
    print("Starting API Tests...")
    print("=" * 50)
    
    # Test CRUD operations
    task_id = test_create_task()
    test_get_tasks()
    test_update_task(task_id)
    test_get_tasks()
    test_delete_task(task_id)
    
    print("\n" + "=" * 50)
    print("API Tests Completed!")

if __name__ == "__main__":
    main()
EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
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

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 11 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with comprehensive instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ Lambda function templates${NC}"
    echo -e "${GREEN}✅ API testing script${NC}"
    echo -e "${GREEN}✅ Terraform example (advanced)${NC}"
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
    echo -e "${BLUE}Difficulty: Intermediate${NC}"
    echo -e "${BLUE}Focus: Serverless Architecture${NC}"
    echo ""
    echo -e "${YELLOW}Key Topics:${NC}"
    echo "• AWS Lambda function development"
    echo "• API Gateway REST API configuration"
    echo "• DynamoDB integration and CRUD operations"
    echo "• IAM roles for serverless security"
    echo "• Event-driven architecture patterns"
    echo "• Complete serverless application testing"
}

# Run main function
main "$@"