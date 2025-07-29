# Lab 7: RDS Database Deployment

**Duration:** 45 minutes  
**Objective:** Deploy and configure Amazon RDS PostgreSQL database with Multi-AZ setup, establish secure connectivity from EC2 instances, and test database operations including failover scenarios.

## Prerequisites
- Completion of Labs 1-4 (EC2, IAM, and VPC setup)
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Basic understanding of SQL and databases

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and configure RDS PostgreSQL database instances
- Implement Multi-AZ deployments for high availability
- Configure database subnet groups and security groups
- Establish secure database connectivity from EC2 instances
- Test database operations and failover scenarios
- Monitor database performance and backup strategies

---

## Task 1: VPC and Security Setup (10 minutes)

### Step 1: Verify VPC Configuration
1. **Navigate to VPC Console:**
   - In the AWS Management Console, go to **VPC** service
   - Verify your VPC from Lab 4 exists: `USERNAME-vpc` ⚠️ **Replace USERNAME**

2. **Check Subnets:**
   - Click **Subnets** in the left navigation
   - Verify you have at least 2 private subnets in different AZs:
     - `USERNAME-private-subnet-1a` (us-east-1a)
     - `USERNAME-private-subnet-1b` (us-east-1b)

> **Note:** If VPC/subnets don't exist, complete Lab 4 first or create basic VPC with public/private subnets.

### Step 2: Create Database Subnet Group
1. **Navigate to RDS Console:**
   - Go to **RDS** service in the AWS Management Console
   - Click **Subnet groups** in the left navigation menu

2. **Create Subnet Group:**
   - Click **Create DB subnet group**
   - **Name:** `USERNAME-rds-subnet-group` ⚠️ **Replace USERNAME**
   - **Description:** `RDS subnet group for USERNAME database`
   - **VPC:** Select your VPC `USERNAME-vpc`

3. **Add Subnets:**
   - **Availability Zones:** Select `us-east-1a` and `us-east-1b`
   - **Subnets:** Select your private subnets from both AZs
   - Click **Create**

### Step 3: Create RDS Security Group
1. **Navigate to EC2 Console:**
   - Go to **EC2** service → **Security Groups**
   - Click **Create security group**

2. **Configure Security Group:**
   - **Name:** `USERNAME-rds-sg` ⚠️ **Replace USERNAME**
   - **Description:** `Security group for USERNAME RDS database`
   - **VPC:** Select your VPC `USERNAME-vpc`

3. **Add Inbound Rules:**
   - **Type:** PostgreSQL
   - **Protocol:** TCP
   - **Port:** 5432
   - **Source:** Custom → Select security group of your EC2 instance from previous labs
   - Click **Create security group**

---

## Task 2: Launch EC2 Instance for Database Access (8 minutes)

### Step 1: Launch EC2 Instance
1. **Navigate to EC2:**
   - Go to **EC2** service → **Instances**
   - Click **Launch instances**

2. **Configure Instance:**
   - **Name:** `USERNAME-db-client` ⚠️ **Replace USERNAME**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro
   - **Key pair:** Use existing or create: `USERNAME-db-key`

3. **Network Settings:**
   - **VPC:** Your VPC `USERNAME-vpc`
   - **Subnet:** Select public subnet (for easy access)
   - **Auto-assign public IP:** Enable
   - **Security group:** Create new `USERNAME-db-client-sg`
   - **Rules:** SSH (22) from 0.0.0.0/0

4. **Launch Instance**

### Step 2: Connect and Install PostgreSQL Client
1. **Connect to Instance:**
   - Use EC2 Instance Connect or SSH
   - Wait for instance to reach "running" state

2. **Install PostgreSQL Client:**
   ```bash
   # Update system
   sudo yum update -y
   
   # Install PostgreSQL client
   sudo yum install -y postgresql15
   
   # Install Python and dependencies for lab scripts
   sudo yum install -y python3 python3-pip
   
   # Verify installation
   psql --version
   python3 --version
   ```

3. **Create Lab Directory:**
   ```bash
   mkdir ~/rds-lab
   cd ~/rds-lab
   ```

---

## Task 3: Create RDS PostgreSQL Database (12 minutes)

### Step 1: Create RDS Instance
1. **Navigate to RDS Console:**
   - Go to **RDS** service
   - Click **Databases** in left navigation
   - Click **Create database**

2. **Database Creation Method:**
   - Select **Standard create**

3. **Engine Options:**
   - **Engine type:** PostgreSQL
   - **Version:** PostgreSQL 15.4-R2 (or latest available)

4. **Availability and Durability:**
   - **Deployment options:** Multi-AZ DB instance ✅

### Step 2: Database Configuration
1. **Settings:**
   - **DB instance identifier:** `USERNAME-postgres-db` ⚠️ **Replace USERNAME**
   - **Master username:** `dbadmin`
   - **Master password:** `SecurePass123!` ⚠️ **Note this password**
   - **Confirm password:** `SecurePass123!`

2. **Instance Configuration:**
   - **DB instance class:** Burstable classes → db.t3.micro
   - **Storage type:** General Purpose SSD (gp2)
   - **Allocated storage:** 20 GiB
   - **Storage autoscaling:** Disable

### Step 3: Connectivity Settings
1. **Connectivity:**
   - **Compute resource:** Don't connect to an EC2 compute resource
   - **VPC:** Select your VPC `USERNAME-vpc`
   - **DB subnet group:** `USERNAME-rds-subnet-group`
   - **Public access:** No
   - **VPC security groups:** Choose existing → `USERNAME-rds-sg`
   - **Availability Zone:** No preference

2. **Database Authentication:**
   - **Database authentication:** Password authentication

### Step 4: Additional Configuration
1. **Database Options:**
   - **Initial database name:** `myappdb`
   - **Parameter group:** default.postgres15
   - **Option group:** default:postgres-15

2. **Backup:**
   - **Backup retention period:** 7 days
   - **Backup window:** No preference
   - **Copy tags to snapshots:** Enable

3. **Monitoring:**
   - **Performance Insights:** Disable (for cost savings)
   - **Enhanced monitoring:** Disable

4. **Maintenance:**
   - **Auto minor version upgrade:** Enable
   - **Maintenance window:** No preference

5. **Deletion Protection:**
   - **Enable deletion protection:** ❌ Uncheck (for lab cleanup)

6. **Create Database:**
   - Review settings
   - Click **Create database**
   - Wait 10-15 minutes for database to become available

---

## Task 4: Test Database Connectivity (10 minutes)

### Step 1: Prepare Database Connection Files
1. **On your EC2 instance, create database configuration:**
   ```bash
   cd ~/rds-lab
   
   # Create database.ini file
   cat > database.ini << 'INI'
   [postgresql]
   host=USERNAME-postgres-db.XXXXXXXXXX.us-east-1.rds.amazonaws.com
   database=myappdb
   user=dbadmin
   password=SecurePass123!
   port=5432
   INI
   ```

2. **Get RDS Endpoint:**
   - In RDS Console, click on your database
   - Copy the **Endpoint** from Connectivity & security section
   - Replace the host value in database.ini with your actual endpoint

### Step 2: Test Direct Connection
1. **Test PostgreSQL Connection:**
   ```bash
   # Connect to RDS using psql
   psql -h YOUR_RDS_ENDPOINT -p 5432 -U dbadmin -d myappdb -W
   # Enter password: SecurePass123!
   ```

2. **Create Sample Table and Data:**
   ```sql
   -- Create a sample table
   CREATE TABLE employees (
       id SERIAL PRIMARY KEY,
       name VARCHAR(100) NOT NULL,
       department VARCHAR(50),
       salary DECIMAL(10,2),
       hire_date DATE DEFAULT CURRENT_DATE
   );
   
   -- Insert sample data
   INSERT INTO employees (name, department, salary) VALUES 
   ('John Doe', 'Engineering', 75000.00),
   ('Jane Smith', 'Marketing', 65000.00),
   ('Bob Johnson', 'Sales', 55000.00),
   ('Alice Brown', 'Engineering', 80000.00);
   
   -- Query the data
   SELECT * FROM employees;
   
   -- Show table info
   \dt
   
   -- Exit psql
   \q
   ```

### Step 3: Create Python Database Script
1. **Install Python dependencies:**
   ```bash
   pip3 install psycopg2-binary configparser
   ```

2. **Create Python database script:**
   ```bash
   cat > query_postgres.py << 'PYTHON'
   #!/usr/bin/env python3
   import psycopg2
   import configparser
   import sys
   import argparse
   
   def connect_db():
       """Connect to PostgreSQL database"""
       config = configparser.ConfigParser()
       config.read('database.ini')
       
       try:
           conn = psycopg2.connect(
               host=config['postgresql']['host'],
               database=config['postgresql']['database'],
               user=config['postgresql']['user'],
               password=config['postgresql']['password'],
               port=config['postgresql']['port']
           )
           return conn
       except psycopg2.Error as e:
           print(f"Error connecting to database: {e}")
           return None
   
   def query_employees():
       """Query employee data"""
       conn = connect_db()
       if conn is None:
           return
       
       try:
           cursor = conn.cursor()
           cursor.execute("SELECT * FROM employees ORDER BY id")
           rows = cursor.fetchall()
           
           print("\n=== Employee Database ===")
           print("ID | Name           | Department  | Salary   | Hire Date")
           print("-" * 60)
           
           for row in rows:
               print(f"{row[0]:2} | {row[1]:14} | {row[2]:11} | {row[3]:8} | {row[4]}")
           
           print(f"\nTotal employees: {len(rows)}")
           
       except psycopg2.Error as e:
           print(f"Error executing query: {e}")
       
       finally:
           if conn:
               conn.close()
   
   def main():
       parser = argparse.ArgumentParser(description='Query PostgreSQL database')
       parser.add_argument('--instance', default='master', help='Database instance type')
       args = parser.parse_args()
       
       print(f"Connecting to {args.instance} database instance...")
       query_employees()
   
   if __name__ == "__main__":
       main()
   PYTHON
   
   chmod +x query_postgres.py
   ```

3. **Test Python Script:**
   ```bash
   python3 ./query_postgres.py --instance master
   ```

---

## Task 5: Test Multi-AZ Failover (5 minutes)

### Step 1: Check Current Instance Location
1. **Check Private IP of Primary:**
   ```bash
   # Ping to get current IP (note this down)
   ping -c 3 YOUR_RDS_ENDPOINT
   ```

2. **Note the IP Address:**
   - Record the private IP address returned
   - This represents the current primary instance

### Step 2: Perform Failover Test
1. **Initiate Failover:**
   - Go to RDS Console → Databases
   - Select your database
   - Click **Actions** → **Reboot**
   - Select **Reboot with failover** ✅
   - Click **Confirm**

2. **Monitor Failover:**
   - Watch database status change to "Rebooting"
   - Wait for status to return to "Available" (2-3 minutes)

3. **Verify IP Change:**
   ```bash
   # Check new IP after failover
   ping -c 3 YOUR_RDS_ENDPOINT
   ```

4. **Test Application Connectivity:**
   ```bash
   # Verify database still works
   python3 ./query_postgres.py --instance master
   ```

### Step 3: Verify Network Interfaces
1. **Check Network Interfaces:**
   - Go to EC2 Console → Network Interfaces
   - Search for your RDS database IPs
   - Notice how the endpoint points to different network interface

---

## Validation and Cleanup

### Validation Checklist
- [ ] Database subnet group created with multiple AZ subnets
- [ ] RDS security group configured with PostgreSQL access
- [ ] EC2 instance can connect to RDS database
- [ ] Sample table created and data inserted
- [ ] Python script successfully queries database
- [ ] Multi-AZ failover completed successfully
- [ ] Database endpoint automatically redirected after failover

### Performance Monitoring
1. **Check RDS Metrics:**
   - Go to RDS Console → Monitoring tab
   - Review CPU, connections, read/write IOPS
   - Note Multi-AZ status in Configuration tab

### Cleanup Instructions
⚠️ **Important:** Clean up resources to avoid charges

1. **Delete RDS Database:**
   ```bash
   # From AWS Console:
   # 1. Go to RDS → Databases
   # 2. Select your database
   # 3. Actions → Delete
   # 4. Uncheck "Create final snapshot"
   # 5. Uncheck "Retain automated backups"
   # 6. Check acknowledgment
   # 7. Type "delete me" to confirm
   # 8. Click Delete
   ```

2. **Delete Subnet Group:**
   - RDS Console → Subnet groups
   - Select and delete your subnet group

3. **Terminate EC2 Instance:**
   - EC2 Console → Instances
   - Terminate the database client instance

4. **Delete Security Groups:**
   - Delete RDS security group
   - Delete EC2 security group (if created)

---

## Troubleshooting

### Common Issues

**Connection Refused:**
- Verify security group allows PostgreSQL (5432) access
- Check that instance is in public subnet with internet access
- Ensure RDS is in same VPC as EC2 instance

**Authentication Failed:**
- Double-check username (dbadmin) and password
- Verify database name (myappdb)
- Check endpoint URL is correct

**Timeout Errors:**
- Verify RDS security group source is EC2 security group ID
- Check subnet group includes subnets from multiple AZs
- Ensure private subnets have NAT gateway for internet access

**Python Script Errors:**
- Install missing dependencies: `pip3 install psycopg2-binary`
- Check database.ini file has correct endpoint
- Verify Python script has execute permissions

### Getting Help
- Check RDS logs in CloudWatch
- Review VPC Flow Logs for network issues
- Use RDS Performance Insights (if enabled)

---

## Key Concepts Summary

### RDS Multi-AZ Benefits
- **High Availability:** Automatic failover to standby instance
- **Data Durability:** Synchronous replication to standby
- **Maintenance:** Updates applied to standby first
- **Backup:** Backups taken from standby to reduce I/O impact

### Security Best Practices
- **Network Isolation:** Deploy RDS in private subnets
- **Access Control:** Use security groups for network-level protection
- **Encryption:** Enable encryption at rest and in transit
- **Authentication:** Use IAM database authentication when possible

### Monitoring and Performance
- **CloudWatch Metrics:** Monitor CPU, connections, IOPS
- **Parameter Groups:** Tune database configuration
- **Read Replicas:** Scale read traffic across multiple instances
- **Performance Insights:** Analyze database performance bottlenecks

## Next Steps
- Explore RDS Read Replicas for read scaling
- Implement database parameter groups for optimization
- Set up automated backups and point-in-time recovery
- Configure RDS Proxy for connection pooling
- Integrate with AWS Secrets Manager for credential management

