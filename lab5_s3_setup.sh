#!/bin/bash

# Lab 5 Setup Script: S3 Static Website Hosting
# AWS Architecting Course - Day 2, Session 1
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
    print_header "AWS Architecting Course - Lab 5 Setup"
    print_status "Setting up S3 Static Website Hosting Lab"
    
    # Create lab directory structure
    LAB_DIR="lab5-s3-static-website"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
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

EOF

    # Create sample HTML files for the website
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>USERNAME's AWS Static Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container">
            <h1>🌐 USERNAME's AWS Static Website</h1>
            <nav>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <li><a href="about.html">About</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container">
        <section class="hero">
            <h2>Welcome to My AWS Learning Journey!</h2>
            <p>This website is hosted on Amazon S3 with CloudFront distribution for optimal performance.</p>
        </section>

        <section class="features">
            <div class="feature-grid">
                <div class="feature-card">
                    <h3>📦 Amazon S3</h3>
                    <p>Static website hosting with high durability and availability</p>
                </div>
                <div class="feature-card">
                    <h3>🚀 CloudFront CDN</h3>
                    <p>Global content delivery for improved performance</p>
                </div>
                <div class="feature-card">
                    <h3>🔒 HTTPS Security</h3>
                    <p>Automatic SSL/TLS encryption for secure connections</p>
                </div>
                <div class="feature-card">
                    <h3>💰 Cost Effective</h3>
                    <p>Pay only for what you use with AWS pricing model</p>
                </div>
            </div>
        </section>

        <section class="lab-info">
            <h3>Lab 5: S3 Static Website Hosting</h3>
            <div class="lab-details">
                <p><strong>Student:</strong> USERNAME</p>
                <p><strong>Duration:</strong> 45 minutes</p>
                <p><strong>Technologies:</strong> Amazon S3, CloudFront, IAM</p>
                <p><strong>Learning Objectives:</strong></p>
                <ul>
                    <li>Configure S3 bucket for static website hosting</li>
                    <li>Implement bucket policies for public access</li>
                    <li>Set up CloudFront distribution for global delivery</li>
                    <li>Optimize website performance and security</li>
                </ul>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <p>&copy; 2025 USERNAME - AWS Architecting Course Lab 5</p>
            <p>Powered by Amazon S3 and CloudFront</p>
        </div>
    </footer>
</body>
</html>
EOF

    cat > about.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - USERNAME's AWS Static Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container">
            <h1>🌐 USERNAME's AWS Static Website</h1>
            <nav>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <li><a href="about.html">About</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container">
        <section class="about-content">
            <h2>About This Lab</h2>
            
            <div class="about-section">
                <h3>🎯 Purpose</h3>
                <p>This static website demonstrates the implementation of AWS S3 static website hosting with CloudFront content delivery network. It serves as a practical example of modern web hosting architecture using cloud services.</p>
            </div>

            <div class="about-section">
                <h3>🏗️ Architecture</h3>
                <div class="architecture-details">
                    <h4>Components:</h4>
                    <ul>
                        <li><strong>Amazon S3:</strong> Object storage service hosting website files</li>
                        <li><strong>CloudFront:</strong> Content delivery network for global distribution</li>
                        <li><strong>IAM Policies:</strong> Access control for public website access</li>
                    </ul>
                    
                    <h4>Benefits:</h4>
                    <ul>
                        <li>High availability and durability (99.999999999%)</li>
                        <li>Global content delivery with low latency</li>
                        <li>Automatic scaling based on demand</li>
                        <li>Cost-effective pay-as-you-go pricing</li>
                        <li>Built-in security features</li>
                    </ul>
                </div>
            </div>

            <div class="about-section">
                <h3>🔧 Technical Implementation</h3>
                <div class="tech-details">
                    <h4>S3 Configuration:</h4>
                    <ul>
                        <li>Bucket: USERNAME-static-website-hosting</li>
                        <li>Region: us-east-1 (N. Virginia)</li>
                        <li>Index Document: index.html</li>
                        <li>Error Document: error.html</li>
                    </ul>
                    
                    <h4>CloudFront Settings:</h4>
                    <ul>
                        <li>Origin: S3 bucket website endpoint</li>
                        <li>Protocol: HTTPS redirect enabled</li>
                        <li>Caching: Optimized for static content</li>
                        <li>Compression: Enabled for better performance</li>
                    </ul>
                </div>
            </div>

            <div class="about-section">
                <h3>📊 Performance Metrics</h3>
                <p>CloudFront provides significant performance improvements:</p>
                <ul>
                    <li>Reduced latency through edge locations</li>
                    <li>Improved Time to First Byte (TTFB)</li>
                    <li>Bandwidth optimization through compression</li>
                    <li>Reduced load on origin S3 bucket</li>
                </ul>
            </div>

            <div class="student-info">
                <h3>👨‍🎓 Student Information</h3>
                <p><strong>Name:</strong> USERNAME</p>
                <p><strong>Lab:</strong> Lab 5 - S3 Static Website Hosting</p>
                <p><strong>Course:</strong> AWS Architecting on Cloud</p>
                <p><strong>Date:</strong> <span id="current-date"></span></p>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <p>&copy; 2025 USERNAME - AWS Architecting Course Lab 5</p>
            <p>Powered by Amazon S3 and CloudFront</p>
        </div>
    </footer>

    <script>
        document.getElementById('current-date').textContent = new Date().toLocaleDateString();
    </script>
</body>
</html>
EOF

    cat > error.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - USERNAME's AWS Static Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container">
            <h1>🌐 USERNAME's AWS Static Website</h1>
            <nav>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <li><a href="about.html">About</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container">
        <section class="error-content">
            <div class="error-message">
                <h1>🔍 404 - Page Not Found</h1>
                <h2>Oops! The page you're looking for doesn't exist.</h2>
                
                <div class="error-details">
                    <p>Don't worry, this error page is working correctly! This demonstrates how S3 static website hosting handles error pages.</p>
                    
                    <div class="error-info">
                        <h3>What happened?</h3>
                        <ul>
                            <li>The requested URL was not found on this website</li>
                            <li>You may have mistyped the URL</li>
                            <li>The page may have been moved or deleted</li>
                            <li>This could be a broken link</li>
                        </ul>
                    </div>

                    <div class="error-actions">
                        <h3>What can you do?</h3>
                        <ul>
                            <li><a href="index.html">🏠 Go back to the homepage</a></li>
                            <li><a href="about.html">📖 Learn about this lab</a></li>
                            <li>Check the URL for typos</li>
                            <li>Use the navigation menu above</li>
                        </ul>
                    </div>
                </div>

                <div class="technical-info">
                    <h3>🔧 Technical Details</h3>
                    <p>This error page is served by:</p>
                    <ul>
                        <li><strong>Amazon S3:</strong> Custom error document configuration</li>
                        <li><strong>CloudFront:</strong> Custom error response handling</li>
                        <li><strong>HTTP Status:</strong> 404 Not Found</li>
                    </ul>
                </div>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <p>&copy; 2025 USERNAME - AWS Architecting Course Lab 5</p>
            <p>Powered by Amazon S3 and CloudFront</p>
        </div>
    </footer>
</body>
</html>
EOF

    cat > style.css << 'EOF'
/* Lab 5: S3 Static Website Hosting - CSS Styles */

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Header Styles */
header {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
    position: sticky;
    top: 0;
    z-index: 1000;
}

header .container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 20px;
}

header h1 {
    color: #4a90e2;
    font-size: 1.5rem;
    font-weight: 600;
}

nav ul {
    display: flex;
    list-style: none;
    gap: 2rem;
}

nav a {
    text-decoration: none;
    color: #333;
    font-weight: 500;
    padding: 0.5rem 1rem;
    border-radius: 5px;
    transition: all 0.3s ease;
}

nav a:hover {
    background: #4a90e2;
    color: white;
    transform: translateY(-2px);
}

/* Main Content */
main {
    padding: 2rem 0;
    flex: 1;
}

/* Hero Section */
.hero {
    text-align: center;
    background: white;
    padding: 3rem 2rem;
    border-radius: 15px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
}

.hero h2 {
    font-size: 2.5rem;
    margin-bottom: 1rem;
    color: #2c3e50;
    background: linear-gradient(45deg, #4a90e2, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.hero p {
    font-size: 1.2rem;
    color: #666;
    max-width: 600px;
    margin: 0 auto;
}

/* Feature Grid */
.features {
    margin: 2rem 0;
}

.feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 2rem;
    margin-top: 2rem;
}

.feature-card {
    background: white;
    padding: 2rem;
    border-radius: 15px;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
    text-align: center;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.feature-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
}

.feature-card h3 {
    font-size: 1.3rem;
    margin-bottom: 1rem;
    color: #4a90e2;
}

.feature-card p {
    color: #666;
    line-height: 1.6;
}

/* Lab Info Section */
.lab-info {
    background: white;
    padding: 2rem;
    border-radius: 15px;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
    margin-top: 2rem;
}

.lab-info h3 {
    color: #2c3e50;
    font-size: 1.8rem;
    margin-bottom: 1.5rem;
    border-bottom: 3px solid #4a90e2;
    padding-bottom: 0.5rem;
}

.lab-details p {
    margin-bottom: 0.5rem;
    font-size: 1.1rem;
}

.lab-details strong {
    color: #4a90e2;
}

.lab-details ul {
    margin-top: 1rem;
    margin-left: 2rem;
}

.lab-details li {
    margin-bottom: 0.5rem;
    color: #666;
}

/* About Page Styles */
.about-content {
    background: white;
    padding: 2rem;
    border-radius: 15px;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
}

.about-content h2 {
    color: #2c3e50;
    font-size: 2.2rem;
    margin-bottom: 2rem;
    text-align: center;
    background: linear-gradient(45deg, #4a90e2, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.about-section {
    margin-bottom: 2rem;
    padding: 1.5rem;
    border-left: 4px solid #4a90e2;
    background: #f8f9fa;
    border-radius: 0 10px 10px 0;
}

.about-section h3 {
    color: #4a90e2;
    font-size: 1.5rem;
    margin-bottom: 1rem;
}

.about-section h4 {
    color: #2c3e50;
    margin: 1rem 0 0.5rem;
}

.about-section ul {
    margin-left: 2rem;
    color: #666;
}

.about-section li {
    margin-bottom: 0.5rem;
}

.architecture-details,
.tech-details {
    margin-top: 1rem;
}

.student-info {
    background: linear-gradient(135deg, #4a90e2, #764ba2);
    color: white;
    padding: 2rem;
    border-radius: 10px;
    margin-top: 2rem;
}

.student-info h3 {
    color: white;
    margin-bottom: 1rem;
}

.student-info p {
    margin-bottom: 0.5rem;
    font-size: 1.1rem;
}

/* Error Page Styles */
.error-content {
    background: white;
    padding: 3rem 2rem;
    border-radius: 15px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    text-align: center;
}

.error-message h1 {
    font-size: 3rem;
    color: #e74c3c;
    margin-bottom: 1rem;
}

.error-message h2 {
    font-size: 1.5rem;
    color: #666;
    margin-bottom: 2rem;
}

.error-details {
    text-align: left;
    max-width: 800px;
    margin: 0 auto;
}

.error-info,
.error-actions,
.technical-info {
    background: #f8f9fa;
    padding: 1.5rem;
    border-radius: 10px;
    margin: 1.5rem 0;
    border-left: 4px solid #e74c3c;
}

.error-actions {
    border-left-color: #27ae60;
}

.technical-info {
    border-left-color: #4a90e2;
}

.error-info h3,
.error-actions h3,
.technical-info h3 {
    color: #2c3e50;
    margin-bottom: 1rem;
}

.error-actions a {
    color: #27ae60;
    text-decoration: none;
    font-weight: 600;
}

.error-actions a:hover {
    text-decoration: underline;
}

/* Footer */
footer {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    color: #666;
    text-align: center;
    padding: 2rem 0;
    margin-top: 2rem;
}

footer p {
    margin-bottom: 0.5rem;
}

/* Responsive Design */
@media (max-width: 768px) {
    header .container {
        flex-direction: column;
        gap: 1rem;
    }

    nav ul {
        gap: 1rem;
    }

    .hero h2 {
        font-size: 2rem;
    }

    .hero p {
        font-size: 1rem;
    }

    .feature-grid {
        grid-template-columns: 1fr;
    }

    .about-section {
        padding: 1rem;
    }

    .error-message h1 {
        font-size: 2rem;
    }
}

/* Animations */
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.feature-card,
.lab-info,
.about-section {
    animation: fadeInUp 0.6s ease forwards;
}

.feature-card:nth-child(2) { animation-delay: 0.1s; }
.feature-card:nth-child(3) { animation-delay: 0.2s; }
.feature-card:nth-child(4) { animation-delay: 0.3s; }
EOF

    # Create lab progress tracking
    cat > lab-progress.md << 'EOF'
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

EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
# Lab 5 Files

This directory contains all files needed for Lab 5: S3 Static Website Hosting.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Website Files

- **index.html** - Main homepage for the static website
- **about.html** - About page explaining the lab and architecture
- **error.html** - Custom 404 error page
- **style.css** - CSS stylesheet for website styling

## Usage

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Upload the HTML and CSS files to your S3 bucket
4. Remember to replace USERNAME with your assigned username throughout

## Important Notes

- Replace USERNAME placeholder with your assigned username (user1, user2, user3, etc.)
- All resource names must include your username prefix for uniqueness
- Follow cleanup instructions carefully to remove all resources
- Test both S3 and CloudFront access methods

## Key Learning Objectives

- S3 static website hosting configuration
- Bucket policies for public access
- CloudFront CDN setup and optimization
- Performance comparison and caching concepts
- HTTPS implementation with CloudFront

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 5 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with complete instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ Sample website files (HTML, CSS)${NC}"
    echo -e "${GREEN}✅ Documentation files${NC}"
    
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. cd $LAB_DIR"
    echo "2. cat README.md  # Read complete lab instructions"
    echo "3. Replace USERNAME with your assigned username in all files"
    echo "4. Follow the step-by-step procedures"
    echo "5. Use lab-progress.md to track completion"
    
    echo ""
    echo -e "${BLUE}Lab Duration: 45 minutes${NC}"
    echo -e "${BLUE}Difficulty: Beginner to Intermediate${NC}"
    echo -e "${BLUE}Focus: S3 Static Website Hosting & CloudFront CDN${NC}"
}

# Run main function
main "$@"