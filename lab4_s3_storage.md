# Lab 4: S3 Static Website Hosting
## Configure S3 for Web Hosting and Content Delivery

**Duration:** 30 minutes  
**Prerequisites:** AWS Management Console access

### Learning Objectives
By the end of this lab, you will be able to:
- Create and configure S3 buckets for static website hosting
- Upload website content and configure permissions
- Enable static website hosting on S3
- Configure bucket policies for public access
- Test website functionality and understand S3 storage classes
- Use AWS CLI for S3 operations
- Understand S3 pricing and optimization strategies

### Architecture Overview
You will create an S3 bucket configured for static website hosting, upload HTML content, configure proper permissions, and access your website through S3's web hosting endpoint.

### Part 1: Activate CloudShell

#### Step 1: Open CloudShell
1. In the AWS Management Console, click the **CloudShell** icon in the top navigation bar
2. Wait for CloudShell to initialize (may take 1-2 minutes on first use)
3. Once ready, you'll see a command prompt

#### Step 2: Configure AWS CLI
1. Configure your AWS CLI credentials:
   ```bash
   aws configure
   ```
2. When prompted, enter:
   - **AWS Access Key ID:** Press Enter (CloudShell uses your session credentials)
   - **AWS Secret Access Key:** Press Enter
   - **Default region name:** `us-east-1`
   - **Default output format:** `json`

3. Verify your identity:
   ```bash
   aws sts get-caller-identity
   ```

### Part 2: Create Website Content

#### Step 1: Create HTML Files
1. In CloudShell, create a directory for your website:
   ```bash
   mkdir my-website
   cd my-website
   ```

2. Create the main HTML file:
   ```bash
   cat > index.html << 'EOF'
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>My AWS Static Website</title>
       <style>
           body {
               font-family: Arial, sans-serif;
               max-width: 800px;
               margin: 0 auto;
               padding: 20px;
               background-color: #f5f5f5;
           }
           .header {
               background-color: #232f3e;
               color: white;
               padding: 20px;
               text-align: center;
               border-radius: 5px;
           }
           .content {
               background-color: white;
               padding: 20px;
               margin: 20px 0;
               border-radius: 5px;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1);
           }
           .aws-logo {
               color: #ff9900;
               font-weight: bold;
           }
       </style>
   </head>
   <body>
       <div class="header">
           <h1>Welcome to My <span class="aws-logo">AWS</span> Static Website</h1>
           <p>Hosted on Amazon S3</p>
       </div>
       
       <div class="content">
           <h2>About This Site</h2>
           <p>This is a static website hosted on Amazon S3, demonstrating:</p>
           <ul>
               <li>S3 Static Website Hosting</li>
               <li>HTML, CSS, and JavaScript content delivery</li>
               <li>Global accessibility through S3</li>
               <li>Cost-effective web hosting solution</li>
           </ul>
       </div>
       
       <div class="content">
           <h2>AWS S3 Features</h2>
           <p>Amazon S3 provides:</p>
           <ul>
               <li>99.999999999% (11 9's) durability</li>
               <li>Multiple storage classes for cost optimization</li>
               <li>Global edge locations for fast content delivery</li>
               <li>Integration with CloudFront CDN</li>
           </ul>
           <p><a href="about.html">Learn more about this project</a></p>
       </div>
   </body>
   </html>
   EOF
   ```

3. Create an about page:
   ```bash
   cat > about.html << 'EOF'
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>About - My AWS Static Website</title>
       <style>
           body {
               font-family: Arial, sans-serif;
               max-width: 800px;
               margin: 0 auto;
               padding: 20px;
               background-color: #f5f5f5;
           }
           .header {
               background-color: #232f3e;
               color: white;
               padding: 20px;
               text-align: center;
               border-radius: 5px;
           }
           .content {
               background-color: white;
               padding: 20px;
               margin: 20px 0;
               border-radius: 5px;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1);
           }
           .aws-logo {
               color: #ff9900;
               font-weight: bold;
           }
       </style>
   </head>
   <body>
       <div class="header">
           <h1>About This <span class="aws-logo">AWS</span> Project</h1>
       </div>
       
       <div class="content">
           <h2>Project Details</h2>
           <p>This static website demonstrates the capabilities of Amazon S3 for web hosting:</p>
           
           <h3>Technology Stack:</h3>
           <ul>
               <li>HTML5 and CSS3</li>
               <li>Amazon S3 Static Website Hosting</li>
               <li>AWS CLI for deployment</li>
           </ul>
           
           <h3>Benefits:</h3>
           <ul>
               <li>No server management required</li>
               <li>Highly scalable and available</li>
               <li>Cost-effective hosting solution</li>
               <li>Easy integration with other AWS services</li>
           </ul>
           
           <p><a href="index.html">← Back to Home</a></p>
       </div>
   </body>
   </html>
   EOF
   ```

4. Create an error page:
   ```bash
   cat > error.html << 'EOF'
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>Error - Page Not Found</title>
       <style>
           body {
               font-family: Arial, sans-serif;
               max-width: 800px;
               margin: 0 auto;
               padding: 20px;
               background-color: #f5f5f5;
           }
           .header {
               background-color: #d32f2f;
               color: white;
               padding: 20px;
               text-align: center;
               border-radius: 5px;
           }
           .content {
               background-color: white;
               padding: 20px;
               margin: 20px 0;
               border-radius: 5px;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1);
           }
       </style>
   </head>
   <body>
       <div class="header">
           <h1>404 - Page Not Found</h1>
       </div>
       
       <div class="content">
           <h2>Oops! Something went wrong.</h2>
           <p>The page you're looking for doesn't exist.</p>
           <p><a href="index.html">← Return to Home Page</a></p>
       </div>
   </body>
   </html>
   EOF
   ```

### Part 3: Create S3 Bucket

#### Step 1: Generate Unique Bucket Name
1. Create a unique bucket name (S3 bucket names must be globally unique):
   ```bash
   BUCKET_NAME="my-static-website-$(date +%s)-$(whoami)"
   echo "Your bucket name will be: $BUCKET_NAME"
   ```

#### Step 2: Create the Bucket
1. Create the S3 bucket:
   ```bash
   aws s3 mb s3://$BUCKET_NAME --region us-east-1
   ```

2. Verify bucket creation:
   ```bash
   aws s3 ls
   ```

### Part 4: Upload Website Files

#### Step 1: Upload Files to S3
1. Upload all website files:
   ```bash
   aws s3 cp index.html s3://$BUCKET_NAME/
   aws s3 cp about.html s3://$BUCKET_NAME/
   aws s3 cp error.html s3://$BUCKET_NAME/
   ```

2. Verify files are uploaded:
   ```bash
   aws s3 ls s3://$BUCKET_NAME/
   ```

#### Step 2: Set Public Read Permissions on Objects
1. Make the files publicly readable:
   ```bash
   aws s3api put-object-acl --bucket $BUCKET_NAME --key index.html --acl public-read
   aws s3api put-object-acl --bucket $BUCKET_NAME --key about.html --acl public-read
   aws s3api put-object-acl --bucket $BUCKET_NAME --key error.html --acl public-read
   ```

### Part 5: Configure Static Website Hosting

#### Step 1: Enable Static Website Hosting via CLI
1. Configure the bucket for static website hosting:
   ```bash
   aws s3 website s3://$BUCKET_NAME --index-document index.html --error-document error.html
   ```

#### Step 2: Configure Bucket Policy for Public Access
1. Create a bucket policy file:
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
               "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
           }
       ]
   }
   EOF
   ```

2. Apply the bucket policy:
   ```bash
   aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json
   ```

#### Step 3: Disable Block Public Access
1. Update block public access settings:
   ```bash
   aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
   ```

### Part 6: Test Your Website

#### Step 1: Get Website URL
1. Get your website endpoint:
   ```bash
   WEBSITE_URL="http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"
   echo "Your website URL is: $WEBSITE_URL"
   ```

#### Step 2: Test Website Access
1. Test the website using curl:
   ```bash
   curl -I $WEBSITE_URL
   ```

2. You should see a `200 OK` response

3. Test error handling:
   ```bash
   curl -I $WEBSITE_URL/nonexistent-page.html
   ```

### Part 7: Configure via AWS Console

#### Step 1: View Bucket in Console
1. Open a new tab and navigate to the **S3** service in AWS Console
2. Find your bucket in the list
3. Click on the bucket name to explore its contents

#### Step 2: Review Static Website Configuration
1. Click the **Properties** tab
2. Scroll down to **Static website hosting**
3. Verify the configuration shows:
   - **Status:** Enabled
   - **Index document:** index.html
   - **Error document:** error.html
   - **Website endpoint:** Your website URL

#### Step 3: Review Permissions
1. Click the **Permissions** tab
2. Review:
   - **Block public access:** All settings should be "Off"
   - **Bucket policy:** Should show your public read policy
   - **Access control list:** Should show public read access

### Part 8: Explore S3 Features

#### Step 1: Test Different S3 Operations
1. List all objects with details:
   ```bash
   aws s3api list-objects-v2 --bucket $BUCKET_NAME
   ```

2. Get object metadata:
   ```bash
   aws s3api head-object --bucket $BUCKET_NAME --key index.html
   ```

3. Copy files within the bucket:
   ```bash
   aws s3 cp s3://$BUCKET_NAME/index.html s3://$BUCKET_NAME/backup-index.html
   ```

#### Step 2: Demonstrate Storage Classes
1. Upload a file with different storage class:
   ```bash
   echo "This is test content for storage class demo" > test-file.txt
   aws s3 cp test-file.txt s3://$BUCKET_NAME/ --storage-class STANDARD_IA
   ```

2. Check the storage class:
   ```bash
   aws s3api head-object --bucket $BUCKET_NAME --key test-file.txt
   ```

#### Step 3: Set Up Lifecycle Policy (Optional)
1. Create a lifecycle policy:
   ```bash
   cat > lifecycle-policy.json << EOF
   {
       "Rules": [
           {
               "ID": "TransitionRule",
               "Status": "Enabled",
               "Filter": {
                   "Prefix": "test-"
               },
               "Transitions": [
                   {
                       "Days": 30,
                       "StorageClass": "STANDARD_IA"
                   },
                   {
                       "Days": 90,
                       "StorageClass": "GLACIER"
                   }
               ]
           }
       ]
   }
   EOF
   ```

2. Apply the lifecycle policy:
   ```bash
   aws s3api put-bucket-lifecycle-configuration --bucket $BUCKET_NAME --lifecycle-configuration file://lifecycle-policy.json
   ```

### Part 9: Monitor and Optimize

#### Step 1: Enable Logging (Optional)
1. Create a logging bucket:
   ```bash
   LOGGING_BUCKET="$BUCKET_NAME-logs"
   aws s3 mb s3://$LOGGING_BUCKET --region us-east-1
   ```

2. Configure access logging:
   ```bash
   cat > logging-config.json << EOF
   {
       "LoggingEnabled": {
           "TargetBucket": "$LOGGING_BUCKET",
           "TargetPrefix": "access-logs/"
       }
   }
   EOF
   
   aws s3api put-bucket-logging --bucket $BUCKET_NAME --bucket-logging-status file://logging-config.json
   ```

#### Step 2: Test Website Performance
1. Access your website in a browser:
   ```bash
   echo "Open this URL in your browser: $WEBSITE_URL"
   ```

2. Test navigation between pages
3. Test the error page by visiting a non-existent URL

### Part 10: Advanced S3 Features (Optional)

#### Step 1: Enable Versioning
1. Enable versioning on your bucket:
   ```bash
   aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
   ```

2. Update a file to create a new version:
   ```bash
   echo "<h1>Updated content</h1>" >> index.html
   aws s3 cp index.html s3://$BUCKET_NAME/
   ```

3. List object versions:
   ```bash
   aws s3api list-object-versions --bucket $BUCKET_NAME --prefix index.html
   ```

#### Step 2: Configure Cross-Origin Resource Sharing (CORS)
1. Create CORS configuration:
   ```bash
   cat > cors-config.json << EOF
   {
       "CORSRules": [
           {
               "AllowedOrigins": ["*"],
               "AllowedMethods": ["GET", "HEAD"],
               "AllowedHeaders": ["*"]
           }
       ]
   }
   EOF
   ```

2. Apply CORS configuration:
   ```bash
   aws s3api put-bucket-cors --bucket $BUCKET_NAME --cors-configuration file://cors-config.json
   ```

### Part 11: Cleanup Resources

⚠️ **Important:** Clean up all resources to avoid charges

#### Step 1: Remove All Objects
1. Remove all objects from the main bucket:
   ```bash
   aws s3 rm s3://$BUCKET_NAME --recursive
   ```

2. Remove objects from logging bucket (if created):
   ```bash
   aws s3 rm s3://$LOGGING_BUCKET --recursive
   ```

#### Step 2: Delete Buckets
1. Delete the main bucket:
   ```bash
   aws s3 rb s3://$BUCKET_NAME
   ```

2. Delete the logging bucket (if created):
   ```bash
   aws s3 rb s3://$LOGGING_BUCKET
   ```

#### Step 3: Verify Cleanup
1. List remaining buckets:
   ```bash
   aws s3 ls
   ```

### Key Concepts Learned

**S3 Static Website Hosting:**
- Cost-effective solution for static content
- Global accessibility without server management
- Integration with CloudFront for better performance

**S3 Storage Classes:**
- Standard: Frequently accessed data
- Standard-IA: Infrequently accessed data
- Glacier: Long-term archival

**S3 Security:**
- Bucket policies for access control
- Public access block settings
- Object-level permissions

**S3 Management:**
- Lifecycle policies for cost optimization
- Versioning for data protection
- Access logging for monitoring

### Troubleshooting Tips

**Website not accessible:**
- Check bucket policy allows public read access
- Verify Block Public Access settings are disabled
- Ensure static website hosting is enabled
- Confirm index document is set correctly

**403 Forbidden errors:**
- Check object-level permissions
- Verify bucket policy syntax
- Ensure principal is set to "*" for public access

**CloudShell issues:**
- Refresh the CloudShell session if it becomes unresponsive
- Use `aws configure list` to verify configuration
- Check region is set to us-east-1

### Next Steps
In the next lab, you'll work with Auto Scaling and Load Balancing to create a highly available and scalable web application architecture that can automatically adjust to traffic demands.