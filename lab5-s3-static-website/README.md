# Lab 5: S3 Static Website Hosting

**Duration:** 45 minutes  
**Objective:** Learn S3 static website hosting, CloudFront integration, and content delivery optimization.

## Prerequisites
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Basic understanding of HTML and web concepts

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and configure S3 buckets for static website hosting
- Upload and manage website content in S3
- Configure CloudFront for global content delivery
- Implement bucket policies for public access
- Understand S3 website endpoints vs CloudFront distribution
- Optimize website performance using CloudFront caching

---

## Task 1: Create S3 Bucket and Upload Website Content (15 minutes)

### Step 1: Create S3 Bucket
1. **Navigate to S3:**
   - In the AWS Management Console, search for "S3"
   - Click on **S3** to open the S3 Dashboard

2. **Create Bucket:**
   - Click **Create bucket**
   - **Bucket name:** `USERNAME-static-website-hosting` ⚠️ **Replace USERNAME with your assigned username**
   - **AWS Region:** US East (N. Virginia) us-east-1
   - **Object Ownership:** ACLs enabled
   - **Block Public Access:** Uncheck "Block all public access" ⚠️ **Important for website hosting**
   - Check the acknowledgment box about public access
   - Leave other settings as default
   - Click **Create bucket**

### Step 2: Upload Website Files
1. **Enter your bucket:**
   - Click on your bucket name (`USERNAME-static-website-hosting`)

2. **Upload HTML files:**
   - Click **Upload**
   - Click **Add files** and select the files created by this script:
     - `index.html`
     - `error.html`
     - `about.html`
     - `style.css`
   - Click **Upload**

### Step 3: Configure Static Website Hosting
1. **Navigate to Properties:**
   - In your bucket, click on the **Properties** tab
   - Scroll down to **Static website hosting**
   - Click **Edit**

2. **Configure hosting:**
   - **Static website hosting:** Enable
   - **Hosting type:** Host a static website
   - **Index document:** `index.html`
   - **Error document:** `error.html`
   - Click **Save changes**

3. **Note the website endpoint:**
   - After saving, note the **Bucket website endpoint** URL
   - It will look like: `http://USERNAME-static-website-hosting.s3-website-us-east-1.amazonaws.com`

---

## Task 2: Configure Bucket Policy for Public Access (10 minutes)

### Step 1: Create Bucket Policy
1. **Navigate to Permissions:**
   - In your bucket, click on the **Permissions** tab
   - Scroll down to **Bucket policy**
   - Click **Edit**

2. **Add bucket policy:**
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "PublicReadGetObject",
               "Effect": "Allow",
               "Principal": "*",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::USERNAME-static-website-hosting/*"
           }
       ]
   }
   ```
   ⚠️ **Important:** Replace `USERNAME-static-website-hosting` with your actual bucket name

3. **Save policy:**
   - Click **Save changes**

### Step 2: Test Website Access
1. **Access via S3 website endpoint:**
   - Open the bucket website endpoint URL in a browser
   - You should see your website homepage
   - Test navigation to different pages
   - Test error page by accessing non-existent URL: `your-endpoint/nonexistent.html`

---

## Task 3: Create CloudFront Distribution (15 minutes)

### Step 1: Create CloudFront Distribution
1. **Navigate to CloudFront:**
   - In AWS Console, search for "CloudFront"
   - Click **Create distribution**

2. **Configure Origin:**
   - **Origin domain:** Select your S3 bucket from dropdown (`USERNAME-static-website-hosting.s3.amazonaws.com`)
   - **Origin access:** Public
   - **Origin path:** Leave empty
   - **Name:** Keep default or use `USERNAME-s3-origin`

3. **Configure Cache Behavior:**
   - **Viewer protocol policy:** Redirect HTTP to HTTPS
   - **Cache key and origin requests:** CachingOptimized
   - **Compress objects automatically:** Yes

4. **Configure Distribution Settings:**
   - **Price class:** Use all edge locations (best performance)
   - **Default root object:** `index.html`
   - **Description:** `USERNAME Static Website Distribution`
   - Click **Create distribution**

### Step 2: Configure Custom Error Pages
1. **Wait for deployment:**
   - Distribution status should show "Deploying" then "Enabled"
   - **Note:** Initial deployment takes 10-15 minutes

2. **Add custom error pages:**
   - Select your distribution
   - Go to **Error pages** tab
   - Click **Create custom error response**
   - **HTTP error code:** 404
   - **Customize error response:** Yes
   - **Response page path:** `/error.html`
   - **HTTP response code:** 404
   - Click **Create custom error response**

### Step 3: Test CloudFront Distribution
1. **Get CloudFront domain name:**
   - In your distribution details, note the **Distribution domain name**
   - It will look like: `d1234567890abc.cloudfront.net`

2. **Test access:**
   - Open CloudFront domain in browser: `https://d1234567890abc.cloudfront.net`
   - Verify the website loads with HTTPS
   - Test different pages and error handling
   - Compare performance with direct S3 access

---

## Task 4: Performance Testing and Optimization (5 minutes)

### Step 1: Compare Performance
1. **Test S3 direct access:**
   - Open S3 website endpoint (HTTP only)
   - Note loading time and network performance

2. **Test CloudFront access:**
   - Open CloudFront distribution URL (HTTPS)
   - Note improved loading time
   - Test from different locations (if possible)

### Step 2: Cache Testing
1. **Update content:**
   - Upload a modified version of `index.html` to S3
   - Access S3 endpoint directly - changes visible immediately
   - Access CloudFront endpoint - changes may take time due to caching

2. **Invalidate cache (optional):**
   - In CloudFront console, go to **Invalidations** tab
   - Click **Create invalidation**
   - **Object paths:** `/*` (invalidates all objects)
   - Click **Create invalidation**

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Disable CloudFront Distribution
1. **Disable distribution:**
   - Select your CloudFront distribution
   - Click **Disable**
   - Wait for status to change to "Disabled" (may take time)

2. **Delete distribution:**
   - After disabling, click **Delete**
   - Confirm deletion

### Step 2: Clean S3 Bucket
1. **Empty bucket:**
   - Go to S3 console
   - Select your bucket (`USERNAME-static-website-hosting`)
   - Click **Empty**
   - Type `permanently delete` to confirm
   - Click **Empty**

2. **Delete bucket:**
   - After emptying, select the bucket
   - Click **Delete**
   - Type the bucket name to confirm
   - Click **Delete bucket**

---

## Troubleshooting

### Common Issues and Solutions

**Issue: "403 Forbidden" error when accessing website**
- **Solution:** Check bucket policy allows public read access
- **Verify:** Block public access settings are disabled

**Issue: Website shows XML error instead of content**
- **Solution:** Ensure you're using the website endpoint, not the bucket endpoint
- **Website endpoint:** `bucket-name.s3-website-region.amazonaws.com`
- **Bucket endpoint:** `bucket-name.s3.region.amazonaws.com`

**Issue: CloudFront shows old content after updates**
- **Solution:** Wait for cache TTL or create invalidation
- **Note:** Default cache TTL is 24 hours

**Issue: SSL/HTTPS issues with CloudFront**
- **Solution:** Ensure distribution status is "Deployed"
- **Verify:** Distribution settings use HTTPS redirect

---

## Validation Checklist

- [ ] S3 bucket created with correct naming (USERNAME prefix)
- [ ] Static website hosting enabled with index and error documents
- [ ] Bucket policy configured for public read access
- [ ] Website accessible via S3 website endpoint
- [ ] CloudFront distribution created and deployed
- [ ] Custom error pages configured in CloudFront
- [ ] Website accessible via CloudFront with HTTPS
- [ ] Performance difference observed between S3 and CloudFront
- [ ] All resources cleaned up properly

---

## Key Concepts Learned

1. **S3 Static Website Hosting:** Simple, cost-effective web hosting solution
2. **Bucket Policies:** JSON-based access control for S3 resources
3. **CloudFront CDN:** Global content delivery network for performance optimization
4. **Website vs Bucket Endpoints:** Different URLs with different capabilities
5. **Cache Management:** Understanding TTL and invalidation strategies
6. **HTTPS/SSL:** Automatic SSL termination with CloudFront
7. **Cost Optimization:** Comparing S3 hosting vs traditional web hosting costs

---

## Advanced Concepts (Optional Exploration)

1. **Custom Domain Names:** Using Route 53 with CloudFront
2. **SSL Certificates:** Custom SSL certificates with ACM
3. **Access Logging:** Analyzing website traffic patterns
4. **Origin Access Control:** Restricting direct S3 access
5. **Lambda@Edge:** Dynamic content processing at edge locations

---

## Next Steps

- **Lab 6:** EBS Volumes & Snapshots
- **Lab 7:** RDS Database Deployment
- **Advanced Topics:** Auto Scaling, Load Balancing, Advanced Networking

---

**Lab Duration:** 45 minutes  
**Difficulty:** Beginner to Intermediate  
**Prerequisites:** AWS Console access, assigned username

