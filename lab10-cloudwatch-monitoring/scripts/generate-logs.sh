#!/bin/bash

# Log generation script for CloudWatch Logs testing
echo "Generating test logs for CloudWatch monitoring..."

# Create log directory if it doesn't exist
sudo mkdir -p /var/log/myapp

# Generate application logs
for i in {1..50}; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    case $((i % 4)) in
        0)
            echo "$timestamp INFO User login successful - UserID: $((RANDOM % 1000))" | sudo tee -a /var/log/myapp/application.log
            ;;
        1)
            echo "$timestamp WARN High memory usage detected - Usage: $((60 + RANDOM % 40))%" | sudo tee -a /var/log/myapp/application.log
            ;;
        2)
            echo "$timestamp ERROR Database connection failed - Timeout after 30s" | sudo tee -a /var/log/myapp/application.log
            ;;
        3)
            echo "$timestamp INFO API request processed - Response time: $((100 + RANDOM % 200))ms" | sudo tee -a /var/log/myapp/application.log
            ;;
    esac
    sleep 2
done

echo "Log generation completed!"
echo "Check CloudWatch Logs console for new log entries."
echo "Log groups should include:"
echo "- USERNAME-apache-access"
echo "- USERNAME-apache-error" 
echo "- USERNAME-application-logs"
