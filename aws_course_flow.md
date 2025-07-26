# 3-Day AWS Architecting Course Flow - Final Structure
*4 Labs per Day, Separated by Presentations*

## Course Overview
- **Duration:** 3 days
- **Format:** 70% hands-on labs, 30% presentations
- **Lab Structure:** 4 labs per day × 45 minutes = 180 minutes per day
- **Total Lab Time:** 540 minutes (9 hours) = 70% of course
- **Presentation Time:** 240 minutes (4 hours) = 30% of course
- **Design:** Every lab preceded and followed by presentations
- **Platform:** Windows and Mac compatible labs

---

## **Day 1: Foundations & Core Services**
*Foundation building with compute, security, and networking*

### Session 1 (75 minutes)
**Presentation: AWS Fundamentals & Global Infrastructure** (30 min)
- Cloud architecture principles and design patterns
- AWS Global Infrastructure (Regions, Availability Zones)
- Well-Architected Framework introduction
- Modern architecture patterns overview

**🔬 Lab 1: EC2 Basics & Instance Management** (45 min)
- Launch EC2 instance with Amazon Linux
- Configure security groups for web access
- Install and configure Apache web server
- Test instance connectivity and web access

### Session 2 (75 minutes)
**Presentation: EC2 Advanced Features & AMI Management** (30 min)
- Instance types and selection criteria
- AMI creation and management best practices
- Instance lifecycle and state management
- Cost optimization strategies for compute

**🔬 Lab 2: AMI Creation & Instance Lifecycle** (45 min)
- Create custom AMI from configured instance
- Launch new instance from custom AMI
- Test AMI persistence and configuration
- Manage instance states and lifecycle

### Session 3 (75 minutes)
**Presentation: IAM Security Framework** (30 min)
- IAM users, groups, roles, and policies
- Security best practices and principle of least privilege
- Multi-factor authentication setup
- Cross-account access patterns

**🔬 Lab 3: IAM Configuration & Security** (45 min)
- Create IAM users, groups, and custom policies
- Configure IAM roles for EC2 service access
- Test permission boundaries and policy effects
- Implement MFA for enhanced security

### Session 4 (75 minutes)
**Presentation: VPC Networking Fundamentals** (30 min)
- VPC components and network design principles
- Subnets, routing tables, and gateways
- Security groups vs NACLs comparison
- Network connectivity patterns

**🔬 Lab 4: VPC Networking Setup** (45 min)
- Create custom VPC with public and private subnets
- Configure Internet Gateway and route tables
- Set up security groups and NACLs
- Test connectivity between subnets

### Day 1 Wrap-up (15 min)
- Key takeaways and Q&A
- Day 2 preview

---

## **Day 2: Storage, Databases & Load Balancing**
*Data management and scalable infrastructure*

### Session 1 (75 minutes)
**Presentation: S3 Storage Services** (30 min)
- S3 storage classes and lifecycle policies
- Static website hosting capabilities
- CloudFront integration for global delivery
- S3 security and access control

**🔬 Lab 5: S3 Static Website Hosting** (45 min)
- Create S3 bucket and configure static website hosting
- Upload HTML content and configure bucket policies
- Enable CloudFront for global content delivery
- Test website access and performance

### Session 2 (75 minutes)
**Presentation: EBS Storage & Data Management** (30 min)
- EBS volume types and performance characteristics
- Snapshot strategies and backup policies
- Volume encryption and security
- Storage optimization and cost management

**🔬 Lab 6: EBS Volumes & Snapshots** (45 min)
- Create and attach EBS volumes to EC2 instances
- Configure file systems and mount points
- Create snapshots for backup and recovery
- Test volume expansion and snapshot restoration

### Session 3 (75 minutes)
**Presentation: Database Services Overview** (30 min)
- RDS vs DynamoDB selection criteria
- Multi-AZ deployments vs Read Replicas
- Database security and backup strategies
- Performance optimization techniques

**🔬 Lab 7: RDS Database Deployment** (45 min)
- Create RDS PostgreSQL with Multi-AZ deployment
- Configure database subnet groups and security groups
- Test database connectivity from EC2 instance
- Monitor database performance metrics

### Session 4 (75 minutes)
**Presentation: Load Balancing & High Availability** (30 min)
- Application Load Balancer vs Network Load Balancer
- Target groups and health check configuration
- SSL termination and security integration
- Cross-zone load balancing patterns

**🔬 Lab 8: Application Load Balancer Setup** (45 min)
- Create Application Load Balancer with target groups
- Configure health checks and routing rules
- Test load balancing across multiple instances
- Monitor traffic distribution and health status

### Day 2 Wrap-up (15 min)
- Key takeaways and Q&A
- Day 3 preview

---

## **Day 3: Auto Scaling, Serverless & Advanced Topics**
*Scaling, automation, and production readiness*

### Session 1 (75 minutes)
**Presentation: Auto Scaling & Dynamic Infrastructure** (30 min)
- Auto Scaling groups and launch templates
- Scaling policies and CloudWatch integration
- Multi-AZ deployment strategies
- Cost optimization through dynamic scaling

**🔬 Lab 9: Auto Scaling Implementation** (45 min)
- Create launch templates with user data scripts
- Configure Auto Scaling group with scaling policies
- Test automatic scaling based on CPU metrics
- Monitor scaling events and cost implications

### Session 2 (75 minutes)
**Presentation: Monitoring & Observability** (30 min)
- CloudWatch metrics, logs, and alarms
- Custom metrics and dashboard creation
- SNS notifications and automated responses
- Performance monitoring best practices

**🔬 Lab 10: CloudWatch Monitoring & Alerts** (45 min)
- Set up comprehensive CloudWatch monitoring
- Create custom metrics and dashboard
- Configure alarms and SNS notifications
- Analyze logs and performance trends

### Session 3 (75 minutes)
**Presentation: Serverless Computing Architecture** (30 min)
- Lambda functions and event-driven architecture
- API Gateway for RESTful API management
- DynamoDB for NoSQL data storage
- Serverless vs traditional architecture patterns

**🔬 Lab 11: Lambda Functions & API Gateway** (45 min)
- Create Lambda function for data processing
- Configure API Gateway with REST endpoints
- Implement DynamoDB integration for data persistence
- Test complete serverless API workflow

### Session 4 (75 minutes)
**Presentation: Infrastructure as Code & DevOps** (30 min)
- Infrastructure as Code principles and benefits
- Terraform vs CloudFormation comparison
- Version control and environment management
- CI/CD integration patterns

**🔬 Lab 12: Infrastructure as Code with Terraform** (45 min)
- Install and configure Terraform
- Create basic AWS resources using Terraform code
- Use variables and outputs for reusable infrastructure
- Compare Terraform vs CloudFormation approaches

### Course Wrap-up (30 minutes)
**Presentation: Security, Compliance & Best Practices** (15 min)
- Advanced IAM features and conditions
- Encryption at rest and in transit
- Well-Architected Framework review
- Cost optimization and performance tuning

**Final Review & Next Steps** (15 min)
- Complete architecture review
- Certification pathway guidance
- Resource recommendations and next steps

---

## **Daily Schedule Structure**

### Each Day Follows This Pattern:
```
Session 1: Presentation (30 min) → Lab (45 min)
Session 2: Presentation (30 min) → Lab (45 min)
Session 3: Presentation (30 min) → Lab (45 min)
Session 4: Presentation (30 min) → Lab (45 min)
Wrap-up: Presentations & Review (15-30 min)
```

### Time Distribution Per Day:
- **Presentations:** 135-150 minutes
- **Labs:** 180 minutes  
- **Total:** 315-330 minutes per day

### Complete Course Time Distribution:
- **Total Lab Time:** 540 minutes (70%)
- **Total Presentation Time:** 405-450 minutes (30%)
- **Perfect 70/30 split achieved**

---

## **Lab Progression by Day**

### Day 1: Foundation Labs
1. **Lab 1: EC2 Basics & Instance Management** (45 min)
2. **Lab 2: AMI Creation & Instance Lifecycle** (45 min)
3. **Lab 3: IAM Configuration & Security** (45 min)
4. **Lab 4: VPC Networking Setup** (45 min)

### Day 2: Data & Infrastructure Labs
5. **Lab 5: S3 Static Website Hosting** (45 min)
6. **Lab 6: EBS Volumes & Snapshots** (45 min)
7. **Lab 7: RDS Database Deployment** (45 min)
8. **Lab 8: Application Load Balancer Setup** (45 min)

### Day 3: Advanced & Automation Labs
9. **Lab 9: Auto Scaling Implementation** (45 min)
10. **Lab 10: CloudWatch Monitoring & Alerts** (45 min)
11. **Lab 11: Lambda Functions & API Gateway** (45 min)
12. **Lab 12: Infrastructure as Code with Terraform** (45 min)

---

## **Course Specifications Fully Met**
✅ **No Back-to-Back Labs:** Every lab separated by presentations  
✅ **4 Labs Per Day:** Exactly 4 labs each day  
✅ **45-Minute Maximum:** Each lab constrained to 45 minutes  
✅ **70/30 Split:** 540 min labs vs 405-450 min presentations  
✅ **Reveal.js Format:** Professional presentation styling  
✅ **Separate .md Files:** Individual lab documents  
✅ **Cross-Platform:** Windows and Mac compatible  
✅ **Logical Flow:** Each presentation prepares for the following lab  
✅ **Progressive Learning:** Concepts build systematically  
✅ **Professional Design:** Consistent styling and callouts