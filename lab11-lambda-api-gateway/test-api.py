#!/usr/bin/env python3
"""
Test script for Lambda Functions & API Gateway Lab
Replace API_URL with your actual API Gateway URL
"""

import requests
import json
import sys

# Replace with your API Gateway URL
API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev"

def test_create_task():
    """Test creating a new task"""
    print("Testing POST /tasks...")
    
    task_data = {
        "title": "Test API Integration",
        "description": "Testing the complete serverless stack",
        "status": "in-progress",
        "priority": "high"
    }
    
    response = requests.post(f"{API_URL}/tasks", json=task_data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    
    if response.status_code == 201:
        return response.json().get('taskId')
    return None

def test_get_tasks():
    """Test getting all tasks"""
    print("\nTesting GET /tasks...")
    
    response = requests.get(f"{API_URL}/tasks")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

def test_update_task(task_id):
    """Test updating a task"""
    if not task_id:
        print("\nSkipping update test - no task ID available")
        return
    
    print(f"\nTesting PUT /tasks/{task_id}...")
    
    update_data = {
        "status": "completed",
        "description": "Updated via API test"
    }
    
    response = requests.put(f"{API_URL}/tasks/{task_id}", json=update_data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

def test_delete_task(task_id):
    """Test deleting a task"""
    if not task_id:
        print("\nSkipping delete test - no task ID available")
        return
    
    print(f"\nTesting DELETE /tasks/{task_id}...")
    
    response = requests.delete(f"{API_URL}/tasks/{task_id}")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

def main():
    if API_URL == "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev":
        print("Please update API_URL in the script with your actual API Gateway URL")
        sys.exit(1)
    
    print("Starting API Tests...")
    print("=" * 50)
    
    # Test CRUD operations
    task_id = test_create_task()
    test_get_tasks()
    test_update_task(task_id)
    test_get_tasks()
    test_delete_task(task_id)
    
    print("\n" + "=" * 50)
    print("API Tests Completed!")

if __name__ == "__main__":
    main()
