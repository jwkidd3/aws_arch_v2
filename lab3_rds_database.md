# Lab 3: RDS Database Deployment
## Deploy Multi-AZ RDS in Private Subnets

**Duration:** 60 minutes  
**Prerequisites:** Completed Lab 2 (VPC Configuration with running EC2 instances)

### Learning Objectives
By the end of this lab, you will be able to:
- Create RDS subnet groups for database deployment
- Configure security groups for database access
- Deploy a Multi-AZ RDS PostgreSQL instance
- Connect to RDS from EC2 instances
- Test database functionality and failover capabilities
- Understand RDS backup and monitoring features

### Architecture Overview
You will deploy an RDS PostgreSQL database in the private subnets created in Lab 2, ensuring secure database access through your public EC2 instance acting as a bastion host.

### Part 1: Create DB Subnet Group

#### Step 1: Navigate to RDS Service
1. In the AWS Management Console, search for and click **RDS**
2. Ensure you're in the **N. Virginia (US-East-1)** region
3. In the left-hand RDS Dashboard navigation menu, click **Subnet groups**

#### Step 2: Create DB Subnet Group
1. If there are any existing subnet groups, select and delete them
2. Click **Create DB Subnet Group**
3. Configure subnet group:
   - **Name:** `myRDSSubnetGroup`
   - **Description:** `Subnet group for RDS deployment in private subnets`
   - **VPC:** Choose `MyProdVPC`
4. **Add subnets:** Select both private subnets from your VPC:
   - `private-subnet-a`
   - `private-subnet-b`
5. Click **Create**

### Part 2: Create Database Security Group

#### Step 1: Navigate to Security Groups
1. Open a new tab and navigate to **EC2** service
2. In the left navigation menu, click **Security Groups**
3. Click **Create security group**

#### Step 2: Configure RDS Security Group
1. **Security group name:** `RDSsg`
2. **Description:** `Security group for RDS database access`
3. **VPC:** Choose `MyProdVPC`
4. **Inbound rules:**
   - Click **Add rule**
   - **Type:** PostgreSQL
   - **Port:** 5432
   - **Source:** Custom
   - **Source value:** Enter the Security Group ID of your Public EC2 Instance
     - *To find this: Go to EC2 > Instances > Select your public instance > Security tab > Note the Security Group ID*
5. **Outbound rules:** Leave default (All traffic)
6. Click **Create security group**

### Part 3: Launch RDS Database Instance

#### Step 1: Create Database
1. Return to the RDS console
2. In the left navigation menu, click **Databases**
3. Click **Create database**

#### Step 2: Configure Database Settings
1. **Database creation method:** Standard create
2. **Engine type:** PostgreSQL
3. **Version:** Use the default latest version
4. **Templates:** Free tier (if available) or Dev/Test

#### Step 3: Configure Availability & Durability
1. **Availability and durability:** Multi-AZ DB instance
2. **DB instance identifier:** `database-1`
3. **Master username:** `postgres` (note this down)
4. **Master password:** Create a strong password and **note it down securely**
5. **Confirm password:** Re-enter the password

#### Step 4: Configure Instance Specifications
1. **DB instance class:** 
   - **Burstable classes:** db.t3.micro
2. **Storage:**
   - **Storage type:** General Purpose SSD (gp2)
   - **Allocated storage:** 30 GB
   - **Storage autoscaling:** Disable

#### Step 5: Configure Connectivity
1. **Compute resource:** Don't connect to an EC2 compute resource
2. **Network type:** IPv4
3. **VPC:** `MyProdVPC`
4. **DB subnet group:** `myRDSSubnetGroup`
5. **Public access:** No
6. **VPC security groups:** Choose existing
   - Remove the default security group
   - Add `RDSsg`
7. **Availability Zone:** No preference
8. **Port:** 5432

#### Step 6: Additional Configuration
1. **Initial database name:** `mydb`
2. **DB parameter group:** Default
3. **Option group:** Default
4. **Backup:**
   - **Enable automated backups:** Yes
   - **Backup retention period:** 7 days
   - **Backup window:** No preference
5. **Monitoring:**
   - **Enable Performance Insights:** Disable
   - **Enable Enhanced monitoring:** Disable
6. **Maintenance:**
   - **Enable auto minor version upgrade:** Yes
   - **Maintenance window:** No preference
7. **Deletion protection:** Disable (for lab purposes)

#### Step 7: Create Database
1. Review all settings
2. Click **Create database**
3. Wait for the database to become **Available** (this takes 10-15 minutes)

### Part 4: Test Database Connectivity

#### Step 1: Prepare Public Instance
1. Start your Public EC2 instance if it's stopped
2. Connect to the public instance using **EC2 Instance Connect**
3. Install PostgreSQL client:
   ```bash
   sudo yum update -y
   sudo amazon-linux-extras install postgresql10 -y
   ```

#### Step 2: Connect to RDS Database
1. In the RDS console, select your database and note the **Endpoint** (hostname)
2. From your public EC2 instance, connect to the database:
   ```bash
   psql -h [RDS-ENDPOINT] -p 5432 -U postgres -W -d mydb
   ```
   - Replace `[RDS-ENDPOINT]` with your actual RDS endpoint
   - Enter the password when prompted

#### Step 3: Test Database Operations
1. Once connected, create a test table:
   ```sql
   CREATE TABLE film (
       title VARCHAR(100) PRIMARY KEY,
       genre VARCHAR(50),
       release_year VARCHAR(5)
   );
   ```

2. Insert sample data:
   ```sql
   INSERT INTO film (title, genre, release_year) VALUES 
   ('The Matrix', 'Sci-Fi', '1999'),
   ('Inception', 'Thriller', '2010'),
   ('Interstellar', 'Sci-Fi', '2014');
   ```

3. Query the data:
   ```sql
   SELECT * FROM film;
   ```

4. Exit PostgreSQL:
   ```sql
   \q
   ```

### Part 5: Test Multi-AZ Failover

#### Step 1: Check Current Database IP
1. From your public EC2 instance, check the current IP of your RDS instance:
   ```bash
   ping -c 1 [RDS-ENDPOINT]
   ```
   - Note the IP address returned

#### Step 2: Initiate Failover
1. In the RDS console, select your database
2. Click **Actions** → **Reboot**
3. **Select:** "Reboot with failover"
4. Click **Confirm**
5. Wait for the reboot to complete (few minutes)

#### Step 3: Verify Failover
1. Once the database is available again, check the IP:
   ```bash
   ping -c 1 [RDS-ENDPOINT]
   ```
   - Note that the IP address has changed (failover to standby)

2. Test database connectivity:
   ```bash
   psql -h [RDS-ENDPOINT] -p 5432 -U postgres -W -d mydb
   ```

3. Verify your data is still there:
   ```sql
   SELECT * FROM film;
   \q
   ```

#### Step 4: Verify Network Interfaces
1. In the EC2 console, navigate to **Network Interfaces**
2. Search for interfaces with "rds" in the description
3. Note the different IP addresses corresponding to the primary and standby instances

### Part 6: Explore RDS Features

#### Step 1: Review Monitoring
1. In RDS console, select your database
2. Click the **Monitoring** tab
3. Observe available CloudWatch metrics:
   - CPU Utilization
   - Database Connections
   - Read/Write IOPS
   - Network Throughput

#### Step 2: Review Backup Settings
1. Click the **Maintenance & backups** tab
2. Review:
   - **Automated backups:** Enabled with 7-day retention
   - **Backup window:** When backups occur
   - **Maintenance window:** When updates are applied

#### Step 3: Review Configuration
1. Click the **Configuration** tab
2. Note the Multi-AZ deployment status
3. Review security group settings
4. Observe subnet group configuration

### Part 7: Python Database Connection (Optional)

#### Step 1: Install Python Dependencies
1. From your public EC2 instance:
   ```bash
   pip3 install psycopg2-binary
   ```

#### Step 2: Create Python Script
1. Create a simple Python script:
   ```bash
   cat > test_db.py << 'EOF'
   import psycopg2
   import sys
   
   # Database connection parameters
   host = "YOUR_RDS_ENDPOINT"
   database = "mydb"
   username = "postgres"
   password = "YOUR_PASSWORD"
   port = 5432
   
   try:
       # Connect to the database
       connection = psycopg2.connect(
           host=host,
           database=database,
           user=username,
           password=password,
           port=port
       )
       
       cursor = connection.cursor()
       
       # Execute a query
       cursor.execute("SELECT title, genre FROM film;")
       records = cursor.fetchall()
       
       print("Movie data from RDS:")
       for row in records:
           print(f"Title: {row[0]}, Genre: {row[1]}")
           
   except Exception as error:
       print(f"Error connecting to database: {error}")
       
   finally:
       if connection:
           cursor.close()
           connection.close()
           print("Database connection closed.")
   EOF
   ```

2. Update the script with your actual RDS endpoint and password:
   ```bash
   nano test_db.py
   ```

3. Run the script:
   ```bash
   python3 test_db.py
   ```

### Part 8: Cleanup Resources

⚠️ **Important:** Clean up resources to avoid charges

#### Step 1: Delete RDS Instance
1. In RDS console, select your database
2. Click **Actions** → **Delete**
3. **Create final snapshot:** No
4. **Retain automated backups:** No
5. **Acknowledgment:** Check the confirmation box
6. Type `delete me` in the confirmation field
7. Click **Delete**

#### Step 2: Delete Supporting Resources
1. **Delete DB Subnet Group:**
   - Navigate to **Subnet groups**
   - Select `myRDSSubnetGroup`
   - Click **Delete**

2. **Delete Security Group:**
   - Navigate to EC2 > Security Groups
   - Select `RDSsg`
   - Click **Actions** → **Delete security groups**

### Key Concepts Learned

**Multi-AZ Deployment:**
- Provides high availability and automatic failover
- Synchronous replication to standby instance
- Different IP addresses for primary and standby

**Database Security:**
- Security groups control network access
- Private subnet deployment prevents direct internet access
- Principle of least privilege for database access

**RDS Management:**
- Automated backups and point-in-time recovery
- CloudWatch monitoring integration
- Maintenance windows for updates

**Database Connectivity:**
- Connection through bastion host (public EC2)
- Standard PostgreSQL client tools
- Application-level database access patterns

### Troubleshooting Tips

**Cannot connect to database:**
- Verify security group allows access from EC2 instance
- Check that database is in "Available" state
- Ensure correct endpoint and port (5432)
- Verify database username and password

**Failover not working:**
- Ensure Multi-AZ is enabled
- Check that both AZs have subnets in subnet group
- Verify network connectivity in both AZs

**Python connection issues:**
- Install psycopg2-binary package
- Check endpoint string has no extra characters
- Verify credentials are correct

### Next Steps
In the next lab, you'll work with storage services including S3, and explore load balancing with Application Load Balancer to distribute traffic across multiple instances.