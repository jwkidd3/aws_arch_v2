# Lab 6: EBS Volumes & Snapshots

**Duration:** 45 minutes  
**Objective:** Learn EBS volume management, filesystem configuration, snapshot creation, and backup strategies.

## Prerequisites
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Existing EC2 instance from previous labs (or create new one)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and attach EBS volumes to EC2 instances
- Configure filesystems and mount points
- Create and manage EBS snapshots
- Restore volumes from snapshots
- Understand EBS volume types and performance characteristics

---

## Task 1: Create and Attach EBS Volume (15 minutes)

### Step 1: Launch EC2 Instance (if needed)
If you don't have a running EC2 instance from previous labs:

1. **Navigate to EC2 Console:**
   - Search for "EC2" in the AWS Management Console
   - Click **Instances** in the left navigation

2. **Launch Instance:**
   - Click **Launch Instances**
   - **Name:** `USERNAME-storage-instance` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro
   - **Key pair:** Use existing or create new `USERNAME-keypair`
   - **Security group:** Allow SSH (22) from 0.0.0.0/0
   - **Launch instance**

### Step 2: Create EBS Volume
1. **Navigate to Volumes:**
   - In EC2 Console, click **Volumes** in the left navigation
   - Note the existing volumes (root volumes of your instances)

2. **Create New Volume:**
   - Click **Create Volume**
   - **Volume Type:** gp3 (General Purpose SSD)
   - **Size:** 10 GiB
   - **Availability Zone:** Select same AZ as your EC2 instance
   - **Add tag:** Key = Name, Value = `USERNAME-data-volume` ⚠️ **Replace USERNAME**
   - Click **Create Volume**

### Step 3: Attach Volume to Instance
1. **Select Volume:**
   - Select your newly created volume (USERNAME-data-volume)
   - Click **Actions** → **Attach Volume**

2. **Configure Attachment:**
   - **Instance:** Select your EC2 instance (USERNAME-storage-instance)
   - **Device name:** `/dev/sdf` (or next available)
   - Click **Attach Volume**

3. **Verify Attachment:**
   - Volume state should show "in-use"
   - Note the device name for next steps

---

## Task 2: Configure Filesystem and Mount Volume (15 minutes)

### Step 1: Connect to Instance
1. **Connect via EC2 Instance Connect:**
   - Select your instance
   - Click **Connect**
   - Use **EC2 Instance Connect**

### Step 2: Check Available Storage
```bash
# List all block devices
lsblk

# Check current disk usage
df -h

# List attached disks
sudo fdisk -l
```

You should see your new volume (typically `/dev/nvme1n1` or `/dev/xvdf`)

### Step 3: Format the Volume
```bash
# Check if volume has filesystem (should show no filesystem initially)
sudo file -s /dev/nvme1n1

# Create ext4 filesystem
sudo mkfs -t ext4 /dev/nvme1n1

# Verify filesystem creation
sudo file -s /dev/nvme1n1
```

### Step 4: Create Mount Point and Mount Volume
```bash
# Create mount point directory
sudo mkdir /data

# Mount the volume temporarily
sudo mount /dev/nvme1n1 /data

# Verify mount
df -h
ls -la /data
```

### Step 5: Configure Persistent Mount
```bash
# Get UUID of the volume
sudo blkid /dev/nvme1n1

# Create backup of fstab
sudo cp /etc/fstab /etc/fstab.backup

# Add entry to fstab for persistent mounting
# Replace UUID_VALUE with actual UUID from blkid command
echo 'UUID=UUID_VALUE /data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Test fstab entry
sudo umount /data
sudo mount -a
df -h
```

### Step 6: Test Volume Functionality
```bash
# Create test file
sudo touch /data/test-file.txt
echo "USERNAME test data" | sudo tee /data/test-file.txt

# Create directory structure
sudo mkdir -p /data/USERNAME-files
sudo chown ec2-user:ec2-user /data/USERNAME-files

# Create some test data
echo "This is test data from USERNAME" > /data/USERNAME-files/sample.txt
date > /data/USERNAME-files/timestamp.txt

# Verify data
ls -la /data/
cat /data/USERNAME-files/sample.txt
```

---

## Task 3: Create and Manage Snapshots (15 minutes)

### Step 1: Create Initial Snapshot
1. **Navigate to Snapshots:**
   - In EC2 Console, click **Snapshots** in the left navigation

2. **Create Snapshot:**
   - Click **Create Snapshot**
   - **Resource type:** Volume
   - **Volume:** Select your data volume (USERNAME-data-volume)
   - **Description:** `USERNAME initial snapshot with test data`
   - **Add tag:** Key = Name, Value = `USERNAME-snapshot-1`
   - Click **Create Snapshot**

### Step 2: Monitor Snapshot Progress
- Snapshots are created asynchronously
- Monitor the **Status** column (pending → completed)
- Note the **Snapshot ID** for later use

### Step 3: Add More Data and Create Second Snapshot
```bash
# Add more test data
echo "Additional data added at $(date)" | sudo tee -a /data/USERNAME-files/sample.txt
sudo mkdir /data/USERNAME-files/logs
echo "Log entry 1" | sudo tee /data/USERNAME-files/logs/app.log
echo "Log entry 2" | sudo tee -a /data/USERNAME-files/logs/app.log

# Verify new data
ls -la /data/USERNAME-files/
cat /data/USERNAME-files/sample.txt
```

Create second snapshot following same process:
- **Description:** `USERNAME snapshot with additional data`
- **Tag:** `USERNAME-snapshot-2`

### Step 4: Create Volume from Snapshot
1. **Create Volume from Snapshot:**
   - In **Snapshots** section, select your first snapshot (USERNAME-snapshot-1)
   - Click **Actions** → **Create Volume from Snapshot**
   - **Volume Type:** gp3
   - **Size:** 10 GiB (or larger)
   - **Availability Zone:** Same as your instance
   - **Tag:** Key = Name, Value = `USERNAME-restored-volume`
   - Click **Create Volume**

2. **Attach Restored Volume:**
   - Once created, attach to your instance with device name `/dev/sdg`

### Step 5: Test Snapshot Restore
```bash
# Create mount point for restored volume
sudo mkdir /restored-data

# Mount the restored volume
sudo mount /dev/nvme2n1 /restored-data

# Compare original and restored data
ls -la /data/USERNAME-files/
ls -la /restored-data/USERNAME-files/

# Check content
cat /data/USERNAME-files/sample.txt
cat /restored-data/USERNAME-files/sample.txt
```

The restored volume should contain only the data from when the first snapshot was created.

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Unmount Volumes
```bash
# Unmount additional volumes
sudo umount /data
sudo umount /restored-data

# Remove entries from fstab (edit file manually)
sudo nano /etc/fstab
# Remove the UUID line you added earlier
```

### Step 2: Detach and Delete Volumes
1. **Detach Volumes:**
   - In EC2 Console → **Volumes**
   - Select USERNAME-data-volume
   - **Actions** → **Detach Volume**
   - Repeat for USERNAME-restored-volume

2. **Delete Volumes:**
   - Select detached volumes
   - **Actions** → **Delete Volume**
   - Confirm deletion

### Step 3: Delete Snapshots
1. **Delete Snapshots:**
   - Go to **Snapshots** section
   - Select USERNAME-snapshot-1 and USERNAME-snapshot-2
   - **Actions** → **Delete Snapshot**
   - Confirm deletion

### Step 4: Clean Up Instance (Optional)
If you created an instance specifically for this lab:
- **Actions** → **Instance State** → **Terminate Instance**

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Volume not appearing in instance**
- **Solution:** Verify volume and instance are in same AZ
- **Check:** Use `lsblk` to see all attached devices

**Issue: Mount fails with "device is busy"**
- **Solution:** Ensure no processes are using the mount point
- **Check:** Use `lsof /data` to see open files

**Issue: Filesystem not persistent after reboot**
- **Solution:** Verify fstab entry is correct
- **Check:** Test with `sudo mount -a` before rebooting

**Issue: Permission denied on mounted volume**
- **Solution:** Check ownership and permissions
- **Fix:** Use `sudo chown ec2-user:ec2-user /data`

**Issue: Snapshot creation is slow**
- **Solution:** This is normal for first snapshot
- **Note:** Incremental snapshots are faster

---

## Validation Checklist

- [ ] Successfully created EBS volume with USERNAME prefix
- [ ] Attached volume to EC2 instance
- [ ] Formatted volume with ext4 filesystem
- [ ] Mounted volume and configured persistent mounting
- [ ] Created test data on mounted volume
- [ ] Created snapshots with proper naming and tags
- [ ] Restored volume from snapshot successfully
- [ ] Verified data integrity in restored volume
- [ ] Properly cleaned up all resources

---

## Key Concepts Learned

1. **EBS Volume Types:** Understanding gp3, io1, and other volume types
2. **Filesystem Management:** Creating, formatting, and mounting filesystems
3. **Persistent Storage:** Configuring automatic mounting with fstab
4. **Snapshot Strategy:** Point-in-time backups and incremental snapshots
5. **Disaster Recovery:** Restoring data from snapshots
6. **Storage Security:** Volume encryption and access controls

---

## Advanced Concepts (Optional)

### Volume Encryption
- EBS volumes can be encrypted at rest
- Encryption is available during volume creation
- Snapshots of encrypted volumes are automatically encrypted

### Performance Optimization
- **gp3:** Baseline 3,000 IOPS, can provision up to 16,000 IOPS
- **io1/io2:** For high IOPS requirements (up to 64,000 IOPS)
- **st1:** Throughput optimized for big data workloads

### Snapshot Best Practices
- Regular snapshot schedule for critical data
- Cross-region snapshot copying for disaster recovery
- Snapshot lifecycle management to control costs
- Application-consistent snapshots for databases

---

## Next Steps

- **Lab 7:** RDS Database Deployment
- **Lab 8:** Application Load Balancer Setup
- **Advanced Topics:** Multi-volume configurations, RAID arrays

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Basic EC2 knowledge, Linux command line familiarity

