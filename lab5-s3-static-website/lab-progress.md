# Lab 5 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Create S3 Bucket and Upload Website Content
- [ ] Navigated to S3 Dashboard
- [ ] Created bucket: `USERNAME-static-website-hosting` (with your username)
- [ ] Configured bucket settings (region, access controls)
- [ ] Uploaded website files (index.html, error.html, about.html, style.css)
- [ ] Enabled static website hosting
- [ ] Configured index document (index.html) and error document (error.html)
- [ ] Noted bucket website endpoint URL

### Task 2: Configure Bucket Policy for Public Access
- [ ] Navigated to bucket Permissions tab
- [ ] Created and applied bucket policy for public read access
- [ ] Updated policy with correct bucket name (USERNAME prefix)
- [ ] Tested website access via S3 endpoint
- [ ] Verified navigation between pages works
- [ ] Tested error page functionality

### Task 3: Create CloudFront Distribution
- [ ] Navigated to CloudFront console
- [ ] Created CloudFront distribution
- [ ] Configured S3 bucket as origin
- [ ] Set viewer protocol policy to redirect HTTP to HTTPS
- [ ] Configured default root object (index.html)
- [ ] Waited for distribution deployment (Enabled status)
- [ ] Added custom error response for 404 errors
- [ ] Noted CloudFront distribution domain name
- [ ] Tested website access via CloudFront URL
- [ ] Verified HTTPS functionality

### Task 4: Performance Testing and Optimization
- [ ] Compared performance between S3 direct access and CloudFront
- [ ] Tested caching behavior
- [ ] (Optional) Created cache invalidation
- [ ] Verified error handling works through CloudFront

### Cleanup
- [ ] Disabled CloudFront distribution
- [ ] Deleted CloudFront distribution (after disabling)
- [ ] Emptied S3 bucket (deleted all objects)
- [ ] Deleted S3 bucket
- [ ] Verified all resources removed

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- S3 Bucket: ________________-static-website-hosting
- CloudFront Distribution: ________________-static-website-distribution

**Important URLs:**
- S3 Website Endpoint: ________________
- CloudFront Distribution Domain: ________________

**Performance Observations:**
- S3 Direct Access Speed: ________________
- CloudFront Access Speed: ________________
- Notable Differences: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Learning Points:**


**Time Completed:** ________________

