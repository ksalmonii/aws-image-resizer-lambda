import boto3
import os
import uuid
import json
import base64
from PIL import Image, ImageFile
from io import BytesIO

# Allow Pillow to load truncated images
ImageFile.LOAD_TRUNCATED_IMAGES = True

# Initialize AWS clients
s3 = boto3.client('s3', region_name='us-east-1')
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

# Environment variables
DEST_BUCKET = os.environ.get('DEST_BUCKET')
TABLE_NAME = os.environ.get('DDB_TABLE')

# CORS headers
CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS,POST',
    'Access-Control-Allow-Headers': 'Content-Type,file-name'
}

def lambda_handler(event, context):
    # Handle CORS preflight request
    if event.get('httpMethod') == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps({'message': 'CORS preflight passed'})
        }

    try:
        # Parse the request body
        body = json.loads(event.get('body', '{}'))
        image_base64 = body.get('image')
        file_name = event.get('headers', {}).get('file-name', 'uploaded.jpg')

        if not image_base64:
            return {
                'statusCode': 400,
                'headers': CORS_HEADERS,
                'body': json.dumps({'message': 'Missing image data in request body'})
            }

        # Decode base64 image
        image_data = base64.b64decode(image_base64)
        original_buffer = BytesIO(image_data)

        # Upload original image to S3
        original_key = f"original/{uuid.uuid4()}_{file_name}"
        print(f"Uploading original image to S3 bucket: {DEST_BUCKET}, key: {original_key}")
        s3.put_object(Bucket=DEST_BUCKET, Key=original_key, Body=original_buffer, ContentType='image/jpeg')

        # Resize image to thumbnail
        image = Image.open(BytesIO(image_data))
        image.thumbnail((128, 128))
        resized_buffer = BytesIO()
        image.save(resized_buffer, format='JPEG')
        resized_buffer.seek(0)

        # Upload resized image to S3
        resized_key = f"resized/{uuid.uuid4()}.jpg"
        print(f"Uploading resized image to S3 bucket: {DEST_BUCKET}, key: {resized_key}")
        s3.put_object(Bucket=DEST_BUCKET, Key=resized_key, Body=resized_buffer, ContentType='image/jpeg')

        # Write metadata to DynamoDB
        image_id = str(uuid.uuid4())
        table = dynamodb.Table(TABLE_NAME)
        item = {
            'imageId': image_id,
            'original_file_name': file_name,
            'original_size': len(image_data),
            'resized_size': resized_buffer.getbuffer().nbytes,
            'original_s3_url': f"s3://{DEST_BUCKET}/{original_key}",
            'resized_s3_url': f"s3://{DEST_BUCKET}/{resized_key}",
            'timestamp': context.aws_request_id
        }
        print(f"Writing item to DynamoDB: {item}")
        table.put_item(Item=item)

        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps({'message': 'Image uploaded, resized, and metadata stored', 'imageId': image_id})
        }

    except Exception as e:
        print(f"Error processing image: {e}")
        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps({'message': f'Error processing image: {str(e)}'})
        }
