# Lab 6 Troubleshooting Guide

## Common Issues and Solutions

### Volume Creation Issues

**Problem:** Cannot create volume in desired AZ
- **Cause:** Instance and volume must be in same AZ
- **Solution:** Check instance AZ and create volume in same zone

**Problem:** Volume creation fails
- **Cause:** Service limits or regional capacity
- **Solution:** Try different volume type or smaller size

### Volume Attachment Issues

**Problem:** Volume not showing in instance
- **Cause:** Wrong AZ or instance not selected properly
- **Solution:** Verify both instance and volume are in same AZ

**Problem:** Device name not available
- **Cause:** Device name already in use
- **Solution:** Use next available device name (sdf, sdg, sdh, etc.)

### Filesystem Issues

**Problem:** `mkfs` command fails
- **Cause:** Volume might already have filesystem or be mounted
- **Solution:** Check with `sudo file -s /dev/device` and unmount if needed

**Problem:** Mount fails with "device or resource busy"
- **Cause:** Directory in use or previous mount exists
- **Solution:** Check with `lsof /data` and kill processes using directory

### Persistent Mount Issues

**Problem:** Volume doesn't mount after reboot
- **Cause:** Incorrect fstab entry
- **Solution:** Check fstab syntax and UUID accuracy

**Problem:** UUID not found
- **Cause:** Incorrect UUID in fstab
- **Solution:** Use `sudo blkid` to get correct UUID

### Snapshot Issues

**Problem:** Snapshot taking very long
- **Cause:** First snapshot copies all data, normal behavior
- **Solution:** Wait for completion, subsequent snapshots are incremental

**Problem:** Cannot create volume from snapshot
- **Cause:** Regional or AZ restrictions
- **Solution:** Ensure snapshot is in same region, volume can be in any AZ

### Permission Issues

**Problem:** Cannot write to mounted volume
- **Cause:** Wrong ownership or permissions
- **Solution:** Use `sudo chown ec2-user:ec2-user /data`

**Problem:** Access denied errors
- **Cause:** SELinux or filesystem permissions
- **Solution:** Check with `ls -laZ` and adjust permissions

## Emergency Recovery

### If Instance Becomes Unresponsive
1. Stop instance (not terminate)
2. Detach root volume
3. Attach root volume to another instance as secondary
4. Mount and fix issues
5. Reattach to original instance

### If Data Volume Corrupted
1. Stop writing to volume immediately
2. Create snapshot if possible
3. Attempt filesystem check: `sudo fsck /dev/device`
4. If fsck fails, restore from last known good snapshot

### If Accidentally Deleted Volume
1. Check if snapshots exist
2. Create new volume from most recent snapshot
3. Attach and mount to recover data

## Performance Optimization

### Volume Performance
- Use gp3 for balanced performance and cost
- Consider io1/io2 for high IOPS requirements
- Monitor CloudWatch metrics for volume performance

### Snapshot Performance
- Schedule snapshots during low-activity periods
- Use snapshot lifecycle policies for cost control
- Consider cross-region copying for disaster recovery

## Best Practices Learned

1. **Always tag resources** with username prefix for identification
2. **Test fstab entries** before rebooting
3. **Create snapshots regularly** for important data
4. **Monitor volume performance** with CloudWatch
5. **Use appropriate volume types** for workload requirements
6. **Clean up resources** to avoid unnecessary charges

