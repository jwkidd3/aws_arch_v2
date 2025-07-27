# Lab 6 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Create and Attach EBS Volume
- [ ] Launched or verified EC2 instance: `USERNAME-storage-instance`
- [ ] Created EBS volume (gp3, 10 GiB): `USERNAME-data-volume`
- [ ] Selected correct Availability Zone
- [ ] Added proper name tag with username prefix
- [ ] Attached volume to instance with device name
- [ ] Verified volume shows "in-use" status

### Task 2: Configure Filesystem and Mount Volume
- [ ] Connected to EC2 instance
- [ ] Checked available storage with `lsblk` and `df -h`
- [ ] Identified new volume device name
- [ ] Formatted volume with ext4 filesystem
- [ ] Created mount point `/data`
- [ ] Mounted volume temporarily
- [ ] Configured persistent mounting in `/etc/fstab`
- [ ] Tested persistent mount configuration
- [ ] Created test data and directories
- [ ] Verified data accessibility

### Task 3: Create and Manage Snapshots
- [ ] Created first snapshot: `USERNAME-snapshot-1`
- [ ] Added proper description and tags
- [ ] Monitored snapshot completion
- [ ] Added additional test data to volume
- [ ] Created second snapshot: `USERNAME-snapshot-2`
- [ ] Created volume from first snapshot: `USERNAME-restored-volume`
- [ ] Attached restored volume to instance
- [ ] Mounted restored volume to `/restored-data`
- [ ] Verified data integrity and point-in-time consistency

### Cleanup
- [ ] Unmounted all additional volumes (`/data`, `/restored-data`)
- [ ] Removed fstab entries for temporary mounts
- [ ] Detached data volume and restored volume
- [ ] Deleted EBS volumes (USERNAME-data-volume, USERNAME-restored-volume)
- [ ] Deleted snapshots (USERNAME-snapshot-1, USERNAME-snapshot-2)
- [ ] Terminated instance if created specifically for lab

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Instance: ________________-storage-instance
- Data Volume: ________________-data-volume
- Restored Volume: ________________-restored-volume
- Snapshot 1: ________________-snapshot-1
- Snapshot 2: ________________-snapshot-2

**Volume IDs:**
- Data Volume: ________________
- Restored Volume: ________________

**Snapshot IDs:**
- Snapshot 1: ________________
- Snapshot 2: ________________

**Device Names:**
- Data Volume: ________________
- Restored Volume: ________________

**Issues Encountered:**


**Solutions Applied:**


**Performance Observations:**


**Time Completed:** ________________

