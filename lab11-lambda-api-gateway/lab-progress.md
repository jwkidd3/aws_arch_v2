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

