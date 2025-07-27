#!/bin/bash
# Memory Load Generation Script for CloudWatch Testing

echo "Starting memory load generation for CloudWatch testing..."

# Check if stress is installed
if ! command -v stress &> /dev/null; then
    echo "Installing stress utility..."
    sudo yum install -y stress
fi

# Generate memory load
echo "Generating memory load (500MB for 5 minutes)..."
stress --vm 1 --vm-bytes 500M --timeout 300s &

echo "Memory load generation started."
echo "Check CloudWatch custom metrics for memory usage."

# Show current memory usage
echo "Current memory usage:"
free -h
