import json
import boto3
import uuid
from datetime import datetime

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('USERNAME-tasks')  # Replace USERNAME with your username

def lambda_handler(event, context):
    try:
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Generate unique task ID
        task_id = str(uuid.uuid4())
        
        # Create task item
        task = {
            'taskId': task_id,
            'title': body.get('title', 'Untitled Task'),
            'description': body.get('description', ''),
            'status': body.get('status', 'pending'),
            'priority': body.get('priority', 'medium'),
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
        
        # Save to DynamoDB
        table.put_item(Item=task)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Task created successfully',
                'taskId': task_id,
                'task': task
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
