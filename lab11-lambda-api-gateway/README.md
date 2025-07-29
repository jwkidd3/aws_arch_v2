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
   - **Settings:** Use default settings
   - Click **Create table**

3. **Verify Table Creation:**
   - Wait for table status to become "Active"
   - Note the table ARN for later use

---

## Task 2: IAM Role for Lambda (5 minutes)

### Step 1: Create Lambda Execution Role
1. **Navigate to IAM:**
   - In the AWS Management Console, search for "IAM"
   - Click **Roles** in the left navigation

2. **Create Role:**
   - Click **Create role**
   - **Trusted entity type:** AWS service
   - **Use case:** Lambda
   - Click **Next**

3. **Attach Permissions:**
   - Search and select **AWSLambdaBasicExecutionRole**
   - Search and select **AmazonDynamoDBFullAccess**
   - Click **Next**

4. **Name and Create:**
   - **Role name:** `USERNAME-lambda-dynamodb-role` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create role**

---

## Task 3: Lambda Functions Creation (20 minutes)

### Step 1: Create Task Function
1. **Navigate to Lambda:**
   - In the AWS Management Console, search for "Lambda"
   - Click **Functions** in the left navigation

2. **Create Function:**
   - Click **Create function**
   - **Function name:** `USERNAME-create-task` ⚠️ **Replace USERNAME with your assigned username**
   - **Runtime:** Python 3.11
   - **Execution role:** Use an existing role
   - **Existing role:** `USERNAME-lambda-dynamodb-role` ⚠️ **Use your username**
   - Click **Create function**

3. **Function Code:**
   Replace the default code with the create task function code from `lambda-functions/create_task.py`

4. **Environment Variables:**
   - **Key:** `TABLE_NAME`
   - **Value:** `USERNAME-tasks` ⚠️ **Replace USERNAME with your username**

5. **Deploy and Test:**
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
   Use the get tasks function code from `lambda-functions/get_tasks.py`

3. **Environment Variables:**
   - Add same TABLE_NAME variable

4. **Deploy and Test:**
   - Test with empty event: `{}`

### Step 3: Create Task Update Function
1. **Create New Function:**
   - **Function name:** `USERNAME-update-task` ⚠️ **Replace USERNAME with your assigned username**
   - Use same runtime and role

2. **Function Code:**
   Use the update task function code from `lambda-functions/update_task.py`

3. **Configure and Test:**
   - Add TABLE_NAME environment variable
   - Test with appropriate event data

### Step 4: Create Task Deletion Function
1. **Create New Function:**
   - **Function name:** `USERNAME-delete-task` ⚠️ **Replace USERNAME with your assigned username**
   - Use same runtime and role

2. **Function Code:**
   Use the delete task function code from `lambda-functions/delete_task.py`

3. **Configure and Test:**
   - Add TABLE_NAME environment variable
   - Test with task ID parameter

---

## Task 4: API Gateway Setup (8 minutes)

### Step 1: Create REST API
1. **Navigate to API Gateway:**
   - In the AWS Management Console, search for "API Gateway"
   - Click **API Gateway**

2. **Create API:**
   - Click **Create API**
   - **REST API** → **Build**
   - **API name:** `USERNAME-tasks-api` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** Task management serverless API
   - Click **Create API**

### Step 2: Create Resources and Methods

1. **Create /tasks Resource:**
   - Click **Actions** → **Create Resource**
   - **Resource Name:** tasks
   - **Resource Path:** /tasks
   - **Enable CORS:** Check this option
   - Click **Create Resource**

2. **Create /{taskId} Resource:**
   - Select `/tasks` resource
   - Click **Actions** → **Create Resource**
   - **Resource Name:** taskId
   - **Resource Path:** /{taskId}
   - **Enable CORS:** Check this option
   - Click **Create Resource**

### Step 3: Configure Methods

1. **POST Method on /tasks:**
   - Select `/tasks` resource
   - Click **Actions** → **Create Method**
   - Select **POST** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-create-task` ⚠️ **Use your username**
   - Click **Save**
   - Click **OK** to give permission

2. **GET Method on /tasks:**
   - Select `/tasks` resource
   - Click **Actions** → **Create Method**
   - Select **GET** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-get-tasks` ⚠️ **Use your username**
   - Click **Save**

3. **GET Method on /{taskId}:**
   - Select `/{taskId}` resource
   - Click **Actions** → **Create Method**
   - Select **GET** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-get-tasks` ⚠️ **Use your username**
   - Click **Save**

4. **PUT Method on /{taskId}:**
   - Select `/{taskId}` resource
   - Click **Actions** → **Create Method**
   - Select **PUT** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-update-task` ⚠️ **Use your username**
   - Click **Save**

5. **DELETE Method on /{taskId}:**
   - Select `/{taskId}` resource
   - Click **Actions** → **Create Method**
   - Select **DELETE** from dropdown
   - **Integration type:** Lambda Function
   - **Lambda Function:** `USERNAME-delete-task` ⚠️ **Use your username**
   - Click **Save**

### Step 4: Deploy API
1. **Deploy to Stage:**
   - Click **Actions** → **Deploy API**
   - **Deployment stage:** [New Stage]
   - **Stage name:** dev
   - Click **Deploy**

2. **Note Invoke URL:**
   - Copy the Invoke URL for testing
   - Format: `https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev`

---

## Task 5: API Testing and Validation (2 minutes)

### Step 1: Test API Endpoints
1. **Test POST /tasks:**
   - In API Gateway console, select POST method under `/tasks`
   - Click **TEST**
   - **Request Body:**
   ```json
   {
     "title": "Test Task",
     "description": "Testing API integration",
     "status": "pending",
     "priority": "medium"
   }
   ```
   - Click **Test**
   - Verify 201 status code and response

2. **Test GET /tasks:**
   - Select GET method under `/tasks`
   - Click **TEST**
   - Click **Test**
   - Verify 200 status code and task list

3. **Test Other Methods:**
   - Test GET, PUT, and DELETE methods on `/{taskId}`
   - Use task ID from previous responses

### Step 2: External Testing (Optional)
Use the provided `test-api.py` script for comprehensive testing:
1. Update API_URL in the script
2. Run: `python3 test-api.py`

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

