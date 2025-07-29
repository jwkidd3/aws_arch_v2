#!/bin/bash

# Memory pressure test script
echo "Starting memory usage test..."

# Generate memory load for 5 minutes
if command -v stress >/dev/null 2>&1; then
    stress --vm 1 --vm-bytes 500M --timeout 300s
else
    echo "Creating memory usage via dd command..."
    dd if=/dev/zero of=/tmp/memory-usage-test bs=1M count=500
    sleep 300
    rm -f /tmp/memory-usage-test
fi

echo "Memory test completed!"
