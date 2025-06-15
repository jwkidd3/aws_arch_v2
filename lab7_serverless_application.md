# Lab 7: Serverless Application
## Build Event-Driven Lambda Functions

**Duration:** 60 minutes  
**Prerequisites:** AWS Management Console access

### Learning Objectives
By the end of this lab, you will be able to:
- Create Lambda functions with different trigger types
- Configure API Gateway for RESTful API management
- Implement DynamoDB for serverless data storage
- Set up S3 event-driven processing workflows
- Build a complete serverless web application
- Monitor and troubleshoot serverless applications
- Understand serverless cost optimization strategies
- Implement error handling and retry mechanisms

### Architecture Overview
You will build a complete serverless application that includes:
- **Frontend:** S3 static website with interactive UI
- **API Layer:** API Gateway with REST endpoints
- **Compute:** Lambda functions for business logic
- **Database:** DynamoDB for data persistence
- **Event Processing:** S3 triggers for file processing
- **Monitoring:** CloudWatch for observability

### Part 1: Create DynamoDB Table

#### Step 1: Navigate to DynamoDB
1. Open **DynamoDB** service in AWS Management Console
2. Ensure you're in the **N. Virginia (US-East-1)** region

#### Step 2: Create Table
1. Click **Create table**
2. **Table details:**
   - **Table name:** `ServerlessApp-Users`
   - **Partition key:** `userId` (String)
   - **Sort key:** Leave empty
3. **Settings:** Use default settings
4. Click **Create table**
5. Wait for table to become **Active**

#### Step 3: Create Items Table
1. Click **Create table** again
2. **Table details:**
   - **Table name:** `ServerlessApp-Items`
   - **Partition key:** `itemId` (String)
   - **Sort key:** `timestamp` (Number)
3. Click **Create table**

### Part 2: Create IAM Role for Lambda

#### Step 1: Create Lambda Execution Role
1. Navigate to **IAM** service
2. Click **Roles** → **Create role**
3. **Trusted entity:** AWS service
4. **Service:** Lambda
5. **Permissions policies:** Add these policies:
   - `AWSLambdaBasicExecutionRole`
   - `AmazonDynamoDBFullAccess`
   - `AmazonS3ReadOnlyAccess`
6. **Role name:** `ServerlessApp-LambdaRole`
7. Click **Create role**

### Part 3: Create Lambda Functions

#### Step 1: Create User Management Function
1. Navigate to **Lambda** service
2. Click **Create function**
3. **Function options:** Author from scratch
4. **Function name:** `UserManager`
5. **Runtime:** Python 3.11
6. **Execution role:** Use existing role → `ServerlessApp-LambdaRole`
7. Click **Create function**

#### Step 2: Implement User Management Code
1. In the **Code** tab, replace the default code:
   ```python
   import json
   import boto3
   import uuid
   from datetime import datetime
   from decimal import Decimal
   
   dynamodb = boto3.resource('dynamodb')
   users_table = dynamodb.Table('ServerlessApp-Users')
   
   def lambda_handler(event, context):
       try:
           # Extract HTTP method and path
           http_method = event['httpMethod']
           path = event['path']
           
           # Handle CORS preflight requests
           if http_method == 'OPTIONS':
               return {
                   'statusCode': 200,
                   'headers': get_cors_headers(),
                   'body': ''
               }
           
           # Route requests based on HTTP method
           if http_method == 'GET':
               return get_users(event)
           elif http_method == 'POST':
               return create_user(event)
           elif http_method == 'PUT':
               return update_user(event)
           elif http_method == 'DELETE':
               return delete_user(event)
           else:
               return {
                   'statusCode': 405,
                   'headers': get_cors_headers(),
                   'body': json.dumps({'error': 'Method not allowed'})
               }
               
       except Exception as e:
           print(f"Error: {str(e)}")
           return {
               'statusCode': 500,
               'headers': get_cors_headers(),
               'body': json.dumps({'error': 'Internal server error'})
           }
   
   def get_users(event):
       try:
           # Get query parameters
           query_params = event.get('queryStringParameters') or {}
           user_id = query_params.get('userId')
           
           if user_id:
               # Get specific user
               response = users_table.get_item(Key={'userId': user_id})
               if 'Item' in response:
                   return {
                       'statusCode': 200,
                       'headers': get_cors_headers(),
                       'body': json.dumps(response['Item'], cls=DecimalEncoder)
                   }
               else:
                   return {
                       'statusCode': 404,
                       'headers': get_cors_headers(),
                       'body': json.dumps({'error': 'User not found'})
                   }
           else:
               # Get all users
               response = users_table.scan()
               return {
                   'statusCode': 200,
                   'headers': get_cors_headers(),
                   'body': json.dumps(response['Items'], cls=DecimalEncoder)
               }
               
       except Exception as e:
           print(f"Error getting users: {str(e)}")
           raise
   
   def create_user(event):
       try:
           # Parse request body
           body = json.loads(event['body'])
           
           # Generate user ID
           user_id = str(uuid.uuid4())
           
           # Create user item
           user = {
               'userId': user_id,
               'name': body['name'],
               'email': body['email'],
               'createdAt': int(datetime.now().timestamp()),
               'status': 'active'
           }
           
           # Save to DynamoDB
           users_table.put_item(Item=user)
           
           return {
               'statusCode': 201,
               'headers': get_cors_headers(),
               'body': json.dumps(user, cls=DecimalEncoder)
           }
           
       except Exception as e:
           print(f"Error creating user: {str(e)}")
           raise
   
   def update_user(event):
       try:
           # Get user ID from path
           path_parts = event['path'].split('/')
           user_id = path_parts[-1]
           
           # Parse request body
           body = json.loads(event['body'])
           
           # Update user
           response = users_table.update_item(
               Key={'userId': user_id},
               UpdateExpression='SET #name = :name, email = :email, updatedAt = :updatedAt',
               ExpressionAttributeNames={'#name': 'name'},
               ExpressionAttributeValues={
                   ':name': body['name'],
                   ':email': body['email'],
                   ':updatedAt': int(datetime.now().timestamp())
               },
               ReturnValues='ALL_NEW'
           )
           
           return {
               'statusCode': 200,
               'headers': get_cors_headers(),
               'body': json.dumps(response['Attributes'], cls=DecimalEncoder)
           }
           
       except Exception as e:
           print(f"Error updating user: {str(e)}")
           raise
   
   def delete_user(event):
       try:
           # Get user ID from path
           path_parts = event['path'].split('/')
           user_id = path_parts[-1]
           
           # Delete user
           users_table.delete_item(Key={'userId': user_id})
           
           return {
               'statusCode': 204,
               'headers': get_cors_headers(),
               'body': ''
           }
           
       except Exception as e:
           print(f"Error deleting user: {str(e)}")
           raise
   
   def get_cors_headers():
       return {
           'Access-Control-Allow-Origin': '*',
           'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
           'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
       }
   
   class DecimalEncoder(json.JSONEncoder):
       def default(self, obj):
           if isinstance(obj, Decimal):
               return float(obj)
           return super(DecimalEncoder, self).default(obj)
   ```

2. Click **Deploy**

#### Step 3: Create File Processing Function
1. Click **Create function**
2. **Function name:** `FileProcessor`
3. **Runtime:** Python 3.11
4. **Execution role:** Use existing role → `ServerlessApp-LambdaRole`
5. Replace the code:
   ```python
   import json
   import boto3
   import uuid
   from datetime import datetime
   from urllib.parse import unquote_plus
   
   dynamodb = boto3.resource('dynamodb')
   s3 = boto3.client('s3')
   items_table = dynamodb.Table('ServerlessApp-Items')
   
   def lambda_handler(event, context):
       try:
           # Process S3 event
           for record in event['Records']:
               # Extract S3 event details
               bucket = record['s3']['bucket']['name']
               key = unquote_plus(record['s3']['object']['key'])
               event_name = record['eventName']
               
               print(f"Processing {event_name} for {key} in {bucket}")
               
               if event_name.startswith('ObjectCreated'):
                   process_file_upload(bucket, key)
               elif event_name.startswith('ObjectRemoved'):
                   process_file_deletion(bucket, key)
           
           return {
               'statusCode': 200,
               'body': json.dumps('File processing completed successfully')
           }
           
       except Exception as e:
           print(f"Error processing file: {str(e)}")
           return {
               'statusCode': 500,
               'body': json.dumps(f'Error: {str(e)}')
           }
   
   def process_file_upload(bucket, key):
       try:
           # Get file metadata
           response = s3.head_object(Bucket=bucket, Key=key)
           file_size = response['ContentLength']
           content_type = response.get('ContentType', 'unknown')
           
           # Create item record
           item = {
               'itemId': str(uuid.uuid4()),
               'timestamp': int(datetime.now().timestamp()),
               'fileName': key,
               'bucket': bucket,
               'fileSize': file_size,
               'contentType': content_type,
               'status': 'processed',
               'eventType': 'upload'
           }
           
           # Save to DynamoDB
           items_table.put_item(Item=item)
           
           print(f"File upload processed: {key}")
           
       except Exception as e:
           print(f"Error processing file upload: {str(e)}")
           raise
   
   def process_file_deletion(bucket, key):
       try:
           # Create deletion record
           item = {
               'itemId': str(uuid.uuid4()),
               'timestamp': int(datetime.now().timestamp()),
               'fileName': key,
               'bucket': bucket,
               'status': 'deleted',
               'eventType': 'deletion'
           }
           
           # Save to DynamoDB
           items_table.put_item(Item=item)
           
           print(f"File deletion processed: {key}")
           
       except Exception as e:
           print(f"Error processing file deletion: {str(e)}")
           raise
   ```

6. Click **Deploy**

### Part 4: Create S3 Bucket for File Processing

#### Step 1: Create S3 Bucket
1. Navigate to **S3** service
2. Click **Create bucket**
3. **Bucket name:** `serverless-app-files-[YOUR-INITIALS]-[TIMESTAMP]`
4. **Region:** US East (N. Virginia)
5. Leave other settings as default
6. Click **Create bucket**

#### Step 2: Configure S3 Event Notification
1. Click on your bucket name
2. Go to **Properties** tab
3. Scroll to **Event notifications**
4. Click **Create event notification**
5. **Event name:** `FileProcessingTrigger`
6. **Event types:** 
   - All object create events
   - All object delete events
7. **Destination:** Lambda function
8. **Lambda function:** `FileProcessor`
9. Click **Save changes**

### Part 5: Create API Gateway

#### Step 1: Create REST API
1. Navigate to **API Gateway** service
2. Click **Create API**
3. **REST API** → Click **Build**
4. **API name:** `ServerlessApp-API`
5. **Description:** `API for serverless application`
6. **Endpoint Type:** Regional
7. Click **Create API**

#### Step 2: Create Users Resource
1. Click **Actions** → **Create Resource**
2. **Resource Name:** `users`
3. **Resource Path:** `/users`
4. **Enable API Gateway CORS:** Check this
5. Click **Create Resource**

#### Step 3: Create Methods for Users Resource
1. With `/users` selected, click **Actions** → **Create Method**
2. Select **GET** from dropdown → Click checkmark
3. **Integration type:** Lambda Function
4. **Lambda Function:** `UserManager`
5. Click **Save** → **OK** (to give permission)

6. Repeat for **POST** method:
   - **Actions** → **Create Method** → **POST**
   - **Lambda Function:** `UserManager`

7. Create a resource for individual users:
   - **Actions** → **Create Resource**
   - **Resource Name:** `user`
   - **Resource Path:** `/users/{userId}`
   - **Enable API Gateway CORS:** Check

8. Add methods to `/users/{userId}`:
   - **GET** method → Lambda Function: `UserManager`
   - **PUT** method → Lambda Function: `UserManager`
   - **DELETE** method → Lambda Function: `UserManager`

#### Step 4: Deploy API
1. Click **Actions** → **Deploy API**
2. **Deployment stage:** `[New Stage]`
3. **Stage name:** `prod`
4. Click **Deploy**
5. **Copy the Invoke URL** - you'll need this later

### Part 6: Create Web Frontend

#### Step 1: Create Frontend S3 Bucket
1. Navigate to **S3** service
2. Create another bucket: `serverless-app-frontend-[YOUR-INITIALS]-[TIMESTAMP]`
3. **Region:** US East (N. Virginia)

#### Step 2: Enable Static Website Hosting
1. Click on the frontend bucket
2. **Properties** tab → **Static website hosting**
3. **Edit** → **Enable**
4. **Index document:** `index.html`
5. **Save changes**

#### Step 3: Create Frontend Files
1. Open **CloudShell** or use local terminal
2. Create the main HTML file:
   ```bash
   cat > index.html << 'EOF'
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>Serverless Application Demo</title>
       <style>
           body {
               font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
               max-width: 1200px;
               margin: 0 auto;
               padding: 20px;
               background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
               min-height: 100vh;
           }
           .container {
               background: white;
               border-radius: 10px;
               padding: 30px;
               box-shadow: 0 10px 30px rgba(0,0,0,0.2);
           }
           .header {
               text-align: center;
               margin-bottom: 30px;
               color: #333;
           }
           .section {
               margin: 30px 0;
               padding: 20px;
               border: 1px solid #e0e0e0;
               border-radius: 8px;
               background: #f9f9f9;
           }
           .form-group {
               margin: 15px 0;
           }
           label {
               display: block;
               margin-bottom: 5px;
               font-weight: bold;
               color: #555;
           }
           input[type="text"], input[type="email"], input[type="file"] {
               width: 100%;
               padding: 10px;
               border: 1px solid #ddd;
               border-radius: 4px;
               font-size: 16px;
           }
           button {
               background: #667eea;
               color: white;
               padding: 12px 24px;
               border: none;
               border-radius: 4px;
               cursor: pointer;
               font-size: 16px;
               margin: 5px;
           }
           button:hover {
               background: #5a6fd8;
           }
           .button-secondary {
               background: #6c757d;
           }
           .button-danger {
               background: #dc3545;
           }
           .users-list {
               margin-top: 20px;
           }
           .user-item {
               background: white;
               padding: 15px;
               margin: 10px 0;
               border-radius: 5px;
               border: 1px solid #ddd;
               display: flex;
               justify-content: space-between;
               align-items: center;
           }
           .file-list {
               margin-top: 20px;
           }
           .file-item {
               background: white;
               padding: 10px;
               margin: 5px 0;
               border-radius: 5px;
               border: 1px solid #ddd;
           }
           .status {
               padding: 10px;
               margin: 10px 0;
               border-radius: 4px;
           }
           .success {
               background: #d4edda;
               color: #155724;
               border: 1px solid #c3e6cb;
           }
           .error {
               background: #f8d7da;
               color: #721c24;
               border: 1px solid #f5c6cb;
           }
           .info {
               background: #d1ecf1;
               color: #0c5460;
               border: 1px solid #bee5eb;
           }
       </style>
   </head>
   <body>
       <div class="container">
           <div class="header">
               <h1>🚀 Serverless Application Demo</h1>
               <p>AWS Lambda + API Gateway + DynamoDB + S3</p>
           </div>
   
           <!-- User Management Section -->
           <div class="section">
               <h2>👥 User Management</h2>
               <div class="form-group">
                   <label for="userName">Name:</label>
                   <input type="text" id="userName" placeholder="Enter user name">
               </div>
               <div class="form-group">
                   <label for="userEmail">Email:</label>
                   <input type="email" id="userEmail" placeholder="Enter user email">
               </div>
               <button onclick="createUser()">Create User</button>
               <button onclick="loadUsers()" class="button-secondary">Load Users</button>
               
               <div id="userStatus"></div>
               <div id="usersList" class="users-list"></div>
           </div>
   
           <!-- File Upload Section -->
           <div class="section">
               <h2>📁 File Processing</h2>
               <div class="form-group">
                   <label for="fileInput">Choose File:</label>
                   <input type="file" id="fileInput" multiple>
               </div>
               <button onclick="uploadFile()">Upload File</button>
               <button onclick="loadFiles()" class="button-secondary">Load File Events</button>
               
               <div id="fileStatus"></div>
               <div id="filesList" class="file-list"></div>
           </div>
   
           <!-- API Configuration -->
           <div class="section">
               <h2>⚙️ Configuration</h2>
               <div class="form-group">
                   <label for="apiUrl">API Gateway URL:</label>
                   <input type="text" id="apiUrl" placeholder="Enter your API Gateway URL">
               </div>
               <div class="form-group">
                   <label for="bucketName">S3 Bucket Name:</label>
                   <input type="text" id="bucketName" placeholder="Enter your S3 bucket name">
               </div>
               <button onclick="saveConfig()">Save Configuration</button>
               <button onclick="loadConfig()" class="button-secondary">Load Configuration</button>
           </div>
       </div>
   
       <script>
           // Configuration variables
           let API_URL = '';
           let BUCKET_NAME = '';
   
           // Load configuration on page load
           window.onload = function() {
               loadConfig();
           };
   
           function saveConfig() {
               API_URL = document.getElementById('apiUrl').value;
               BUCKET_NAME = document.getElementById('bucketName').value;
               
               localStorage.setItem('serverlessApp_apiUrl', API_URL);
               localStorage.setItem('serverlessApp_bucketName', BUCKET_NAME);
               
               showStatus('Configuration saved successfully!', 'success', 'userStatus');
           }
   
           function loadConfig() {
               API_URL = localStorage.getItem('serverlessApp_apiUrl') || '';
               BUCKET_NAME = localStorage.getItem('serverlessApp_bucketName') || '';
               
               document.getElementById('apiUrl').value = API_URL;
               document.getElementById('bucketName').value = BUCKET_NAME;
           }
   
           async function createUser() {
               if (!API_URL) {
                   showStatus('Please configure API URL first!', 'error', 'userStatus');
                   return;
               }
   
               const name = document.getElementById('userName').value;
               const email = document.getElementById('userEmail').value;
   
               if (!name || !email) {
                   showStatus('Please enter both name and email!', 'error', 'userStatus');
                   return;
               }
   
               try {
                   const response = await fetch(`${API_URL}/users`, {
                       method: 'POST',
                       headers: {
                           'Content-Type': 'application/json',
                       },
                       body: JSON.stringify({ name, email })
                   });
   
                   if (response.ok) {
                       const user = await response.json();
                       showStatus(`User created successfully! ID: ${user.userId}`, 'success', 'userStatus');
                       document.getElementById('userName').value = '';
                       document.getElementById('userEmail').value = '';
                       loadUsers();
                   } else {
                       throw new Error(`HTTP ${response.status}`);
                   }
               } catch (error) {
                   showStatus(`Error creating user: ${error.message}`, 'error', 'userStatus');
               }
           }
   
           async function loadUsers() {
               if (!API_URL) {
                   showStatus('Please configure API URL first!', 'error', 'userStatus');
                   return;
               }
   
               try {
                   const response = await fetch(`${API_URL}/users`);
                   if (response.ok) {
                       const users = await response.json();
                       displayUsers(users);
                       showStatus(`Loaded ${users.length} users`, 'info', 'userStatus');
                   } else {
                       throw new Error(`HTTP ${response.status}`);
                   }
               } catch (error) {
                   showStatus(`Error loading users: ${error.message}`, 'error', 'userStatus');
               }
           }
   
           function displayUsers(users) {
               const usersList = document.getElementById('usersList');
               if (users.length === 0) {
                   usersList.innerHTML = '<p>No users found.</p>';
                   return;
               }
   
               usersList.innerHTML = users.map(user => `
                   <div class="user-item">
                       <div>
                           <strong>${user.name}</strong><br>
                           <small>${user.email} | ID: ${user.userId}</small><br>
                           <small>Created: ${new Date(user.createdAt * 1000).toLocaleString()}</small>
                       </div>
                       <button onclick="deleteUser('${user.userId}')" class="button-danger">Delete</button>
                   </div>
               `).join('');
           }
   
           async function deleteUser(userId) {
               if (!confirm('Are you sure you want to delete this user?')) return;
   
               try {
                   const response = await fetch(`${API_URL}/users/${userId}`, {
                       method: 'DELETE'
                   });
   
                   if (response.ok) {
                       showStatus('User deleted successfully!', 'success', 'userStatus');
                       loadUsers();
                   } else {
                       throw new Error(`HTTP ${response.status}`);
                   }
               } catch (error) {
                   showStatus(`Error deleting user: ${error.message}`, 'error', 'userStatus');
               }
           }
   
           async function uploadFile() {
               const fileInput = document.getElementById('fileInput');
               const files = fileInput.files;
   
               if (files.length === 0) {
                   showStatus('Please select at least one file!', 'error', 'fileStatus');
                   return;
               }
   
               if (!BUCKET_NAME) {
                   showStatus('Please configure S3 bucket name first!', 'error', 'fileStatus');
                   return;
               }
   
               showStatus('Note: File upload requires AWS credentials. This demo shows the UI only.', 'info', 'fileStatus');
               
               for (let file of files) {
                   showStatus(`Would upload: ${file.name} (${file.size} bytes)`, 'info', 'fileStatus');
               }
           }
   
           async function loadFiles() {
               // Since we can't directly query DynamoDB from the browser,
               // this would typically be another API endpoint
               showStatus('File events would be loaded from DynamoDB via another API endpoint', 'info', 'fileStatus');
               
               // Mock data for demonstration
               const mockFiles = [
                   {
                       fileName: 'example.txt',
                       eventType: 'upload',
                       timestamp: Date.now() / 1000,
                       fileSize: 1024
                   },
                   {
                       fileName: 'image.jpg',
                       eventType: 'upload',
                       timestamp: Date.now() / 1000 - 3600,
                       fileSize: 51200
                   }
               ];
               
               displayFiles(mockFiles);
           }
   
           function displayFiles(files) {
               const filesList = document.getElementById('filesList');
               if (files.length === 0) {
                   filesList.innerHTML = '<p>No file events found.</p>';
                   return;
               }
   
               filesList.innerHTML = files.map(file => `
                   <div class="file-item">
                       <strong>${file.fileName}</strong> - ${file.eventType}<br>
                       <small>Time: ${new Date(file.timestamp * 1000).toLocaleString()}</small>
                       ${file.fileSize ? `<br><small>Size: ${formatFileSize(file.fileSize)}</small>` : ''}
                   </div>
               `).join('');
           }
   
           function formatFileSize(bytes) {
               if (bytes === 0) return '0 Bytes';
               const k = 1024;
               const sizes = ['Bytes', 'KB', 'MB', 'GB'];
               const i = Math.floor(Math.log(bytes) / Math.log(k));
               return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
           }
   
           function showStatus(message, type, elementId) {
               const statusDiv = document.getElementById(elementId);
               statusDiv.innerHTML = `<div class="status ${type}">${message}</div>`;
               
               // Auto-clear after 5 seconds for success/info messages
               if (type === 'success' || type === 'info') {
                   setTimeout(() => {
                       statusDiv.innerHTML = '';
                   }, 5000);
               }
           }
       </script>
   </body>
   </html>
   EOF
   ```

#### Step 4: Upload Frontend to S3
1. Upload the HTML file to your frontend bucket:
   ```bash
   aws s3 cp index.html s3://[YOUR-FRONTEND-BUCKET-NAME]/
   ```

2. Make the file publicly readable:
   ```bash
   aws s3api put-object-acl --bucket [YOUR-FRONTEND-BUCKET-NAME] --key index.html --acl public-read
   ```

3. Configure bucket policy for public access:
   ```bash
   cat > bucket-policy.json << EOF
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "PublicReadGetObject",
               "Effect": "Allow",
               "Principal": "*",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::YOUR-FRONTEND-BUCKET-NAME/*"
           }
       ]
   }
   EOF
   
   # Replace YOUR-FRONTEND-BUCKET-NAME with your actual bucket name
   aws s3api put-bucket-policy --bucket [YOUR-FRONTEND-BUCKET-NAME] --policy file://bucket-policy.json
   ```

4. Disable block public access:
   ```bash
   aws s3api put-public-access-block --bucket [YOUR-FRONTEND-BUCKET-NAME] --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
   ```

### Part 7: Test the Serverless Application

#### Step 1: Get Website URL
1. Navigate to your frontend S3 bucket
2. **Properties** tab → **Static website hosting**
3. Copy the **Bucket website endpoint**

#### Step 2: Configure the Application
1. Open the website URL in your browser
2. In the **Configuration** section:
   - Enter your **API Gateway URL** (from Part 5, Step 4)
   - Enter your **S3 bucket name** (for file processing)
3. Click **Save Configuration**

#### Step 3: Test User Management
1. **Create a user:**
   - Enter name and email
   - Click **Create User**
   - Verify success message with user ID

2. **Load users:**
   - Click **Load Users**
   - See the created user in the list

3. **Delete a user:**
   - Click **Delete** next to a user
   - Confirm deletion
   - Verify user is removed

#### Step 4: Test File Processing
1. **Upload a test file:**
   - Navigate to your file processing S3 bucket
   - Upload any file manually through the console

2. **Check DynamoDB:**
   - Navigate to **DynamoDB** → **Tables** → `ServerlessApp-Items`
   - **Explore table items**
   - Verify file processing event was recorded

### Part 8: Monitor the Application

#### Step 1: View Lambda Logs
1. Navigate to **CloudWatch** → **Log groups**
2. Find log groups for your Lambda functions:
   - `/aws/lambda/UserManager`
   - `/aws/lambda/FileProcessor`
3. Click on recent log streams to view execution logs

#### Step 2: Check API Gateway Metrics
1. Navigate to **API Gateway** → **ServerlessApp-API**
2. **Monitoring** tab
3. Review metrics:
   - Request count
   - Latency
   - Error rates

#### Step 3: DynamoDB Metrics
1. Navigate to **DynamoDB** → **Tables**
2. Select each table
3. **Monitoring** tab → Review:
   - Read/Write capacity
   - Throttled requests
   - Item count

### Part 9: Error Handling and Testing

#### Step 1: Test Error Scenarios
1. **Invalid API requests:**
   - Try creating a user with missing fields
   - Send malformed JSON
   - Verify error responses

2. **Lambda function errors:**
   - Check CloudWatch logs for errors
   - Review retry behavior

#### Step 2: Test Scaling
1. **Generate multiple requests:**
   ```bash
   # Use curl to test API concurrency
   for i in {1..10}; do
       curl -X POST [YOUR-API-URL]/users \
           -H "Content-Type: application/json" \
           -d '{"name":"User'$i'","email":"user'$i'@example.com"}' &
   done
   ```

2. **Monitor concurrency:**
   - Check Lambda function metrics
   - Review execution duration

### Part 10: Advanced Features (Optional)

#### Step 1: Add API Authentication
1. Navigate to **API Gateway** → **Authorizers**
2. Create an API key:
   - **API Gateway** → **API Keys** → **Create API key**
   - **Actions** → **Create usage plan**
   - Associate with your API

#### Step 2: Add Lambda Layers
1. Create a shared layer for common dependencies
2. Upload to Lambda layer
3. Attach to multiple functions

#### Step 3: Set Up Dead Letter Queues
1. Create an SQS queue for failed Lambda executions
2. Configure DLQ in Lambda function settings
3. Monitor failed executions

### Part 11: Cost Optimization

#### Step 1: Review Pricing
1. **Lambda costs:**
   - Request charges
   - Duration charges
   - Memory allocation impact

2. **API Gateway costs:**
   - Request charges
   - Data transfer

3. **DynamoDB costs:**
   - Read/Write capacity units
   - Storage costs

#### Step 2: Optimization Strategies
1. **Right-size Lambda memory**
2. **Use provisioned concurrency carefully**
3. **Implement caching where appropriate**
4. **Optimize DynamoDB capacity modes**

### Part 12: Cleanup Resources

⚠️ **Important:** Clean up all resources to avoid charges

#### Step 1: Delete Lambda Functions
1. Navigate to **Lambda** → **Functions**
2. Delete:
   - `UserManager`
   - `FileProcessor`

#### Step 2: Delete API Gateway
1. Navigate to **API Gateway**
2. Select `ServerlessApp-API`
3. **Actions** → **Delete**

#### Step 3: Delete DynamoDB Tables
1. Navigate to **DynamoDB** → **Tables**
2. Delete:
   - `ServerlessApp-Users`
   - `ServerlessApp-Items`

#### Step 4: Delete S3 Buckets
1. Empty and delete both S3 buckets:
   ```bash
   aws s3 rm s3://[YOUR-FILE-BUCKET] --recursive
   aws s3 rb s3://[YOUR-FILE-BUCKET]
   
   aws s3 rm s3://[YOUR-FRONTEND-BUCKET] --recursive
   aws s3 rb s3://[YOUR-FRONTEND-BUCKET]
   ```

#### Step 5: Delete IAM Role
1. Navigate to **IAM** → **Roles**
2. Delete `ServerlessApp-LambdaRole`

### Key Concepts Learned

**Serverless Architecture:**
- Event-driven computing without server management
- Automatic scaling from zero to high concurrency
- Pay-per-execution pricing model
- Built-in high availability and fault tolerance

**Lambda Functions:**
- Multiple trigger types (API Gateway, S3, DynamoDB)
- Runtime environments and memory allocation
- Error handling and retry mechanisms
- Monitoring and logging integration

**API Gateway:**
- REST API creation and management
- CORS configuration for web applications
- Integration with Lambda backend services
- Request/response transformation capabilities

**DynamoDB Integration:**
- NoSQL database for serverless applications
- High-performance read/write operations
- Event-driven processing with DynamoDB Streams
- Cost-effective scaling strategies

**Event-Driven Patterns:**
- S3 event notifications triggering Lambda
- Asynchronous processing workflows
- Decoupled architecture components
- Real-time data processing capabilities

### Troubleshooting Tips

**Lambda function errors:**
- Check CloudWatch logs for detailed error messages
- Verify IAM permissions for resource access
- Test function locally before deployment
- Monitor function timeout and memory settings

**API Gateway issues:**
- Enable CORS for browser-based applications
- Check method integration configuration
- Verify deployment to correct stage
- Test with API Gateway test console

**DynamoDB problems:**
- Verify table exists and is active
- Check IAM permissions for table operations
- Monitor capacity and throttling metrics
- Validate item structure and data types

**S3 event processing:**
- Confirm event notification configuration
- Check bucket permissions for Lambda access
- Verify event types match function expectations
- Monitor CloudWatch logs for processing errors

### Next Steps
This serverless application demonstrates:
- Modern application architecture patterns
- Event-driven processing workflows
- Cost-effective scaling strategies
- Integration between multiple AWS services

In production environments, you would also implement:
- Authentication and authorization (Cognito)
- Error monitoring and alerting
- Performance optimization and caching
- Infrastructure as Code (CloudFormation/CDK)
- CI/CD pipelines for automated deployment