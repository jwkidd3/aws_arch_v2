#!/bin/bash
# CPU Load Generation Script for CloudWatch Testing

echo "Starting CPU load generation for CloudWatch alarm testing..."
echo "This will generate high CPU usage for 5 minutes to trigger alarms"

# Check if stress is installed
if ! command -v stress &> /dev/null; then
    echo "Installing stress utility..."
    sudo yum install -y stress
fi

# Generate CPU load
echo "Generating CPU load (2 cores, 5 minutes)..."
stress --cpu 2 --timeout 300s &

# Monitor progress
echo "Load generation started. Monitor CloudWatch dashboard and alarms."
echo "CPU usage should increase and trigger alarms after 2 consecutive periods above threshold."

# Show current load
echo "Current system load:"
uptime
cat /proc/loadavg

echo "Load generation will complete automatically in 5 minutes."
echo "Check your email for CloudWatch alarm notifications."
