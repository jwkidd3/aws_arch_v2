#!/bin/bash
# Log Generation Script for CloudWatch Logs Testing

echo "Generating sample application logs for CloudWatch Logs testing..."

# Create application log directory if it doesn't exist
sudo mkdir -p /var/log/myapp

# Generate sample logs with various log levels
LOG_FILE="/var/log/myapp/application.log"

# Function to add log entry
add_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | sudo tee -a $LOG_FILE > /dev/null
}

# Generate various log entries
add_log "INFO Application startup completed"
add_log "INFO Database connection established"
add_log "INFO User USERNAME logged in successfully"
add_log "WARN Memory usage is at 85%"
add_log "INFO Processing user request ID: $(shuf -i 10000-99999 -n 1)"
add_log "ERROR Failed to connect to external API - connection timeout"
add_log "WARN Retry attempt 1 for external API"
add_log "INFO External API connection restored"
add_log "INFO User request processed successfully"
add_log "DEBUG Cache hit rate: 92%"

# Generate Apache access logs by making requests
echo "Generating Apache access logs..."
for i in {1..10}; do
    curl -s http://localhost/ > /dev/null
    sleep 1
done

echo "Log generation completed."
echo "Check CloudWatch Logs console for new log entries."
echo "Log groups should include:"
echo "- USERNAME-apache-access"
echo "- USERNAME-apache-error" 
echo "- USERNAME-application-logs"
