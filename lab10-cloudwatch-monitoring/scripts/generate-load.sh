#!/bin/bash

# Script to generate various types of load for CloudWatch testing
# Usage: ./generate-load.sh [cpu|memory|disk|network] [duration_seconds]

LOAD_TYPE=${1:-cpu}
DURATION=${2:-300}

echo "Generating $LOAD_TYPE load for $DURATION seconds..."

case $LOAD_TYPE in
    cpu)
        echo "Starting CPU stress test..."
        if command -v stress >/dev/null 2>&1; then
            stress --cpu 2 --timeout ${DURATION}s
        else
            echo "stress command not found, using alternative method..."
            for i in {1..2}; do
                yes > /dev/null &
            done
            sleep $DURATION
            pkill yes
        fi
        ;;
    memory)
        echo "Starting memory stress test..."
        if command -v stress >/dev/null 2>&1; then
            stress --vm 1 --vm-bytes 256M --timeout ${DURATION}s
        else
            echo "Creating memory pressure..."
            dd if=/dev/zero of=/tmp/memory-test bs=1M count=256
            sleep $DURATION
            rm -f /tmp/memory-test
        fi
        ;;
    disk)
        echo "Starting disk I/O stress test..."
        for i in $(seq 1 10); do
            dd if=/dev/zero of=/tmp/testfile$i bs=1M count=50 2>/dev/null
            rm -f /tmp/testfile$i
        done
        ;;
    network)
        echo "Starting network activity..."
        for i in $(seq 1 $((DURATION/10))); do
            curl -s https://httpbin.org/bytes/1024 > /dev/null
            sleep 10
        done
        ;;
    *)
        echo "Unknown load type: $LOAD_TYPE"
        echo "Usage: $0 [cpu|memory|disk|network] [duration_seconds]"
        exit 1
        ;;
esac

echo "Load test completed!"
