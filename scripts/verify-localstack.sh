#!/bin/bash

# Exit on error
set -e

echo "Checking LocalStack health (any valid JSON response)..."

for i in {1..30}; do
  response=$(curl -s http://localhost:4566/health)
  if echo "$response" | jq . > /dev/null 2>&1; then
    echo "LocalStack /health endpoint returned valid JSON!"
    exit 0
  fi
  echo "Waiting for valid JSON from /health... ($i/30)"
  sleep 1
done

echo "LocalStack /health did not return valid JSON in time."
exit 1

# Set AWS environment variables for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
for i in {1..30}; do
  if aws --endpoint-url=http://localhost:4566 dynamodb list-tables > /dev/null 2>&1; then
    echo "LocalStack is ready!"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "LocalStack failed to start within 30 seconds"
    exit 1
  fi
  echo "Waiting for LocalStack to be ready... ($i/30)"
  sleep 1
done

# List resources to verify
echo "Listing DynamoDB tables..."
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

echo "Listing SQS queues..."
aws --endpoint-url=http://localhost:4566 sqs list-queues

echo "Listing SNS topics..."
aws --endpoint-url=http://localhost:4566 sns list-topics

echo "Listing S3 buckets..."
aws --endpoint-url=http://localhost:4566 s3 ls

echo "Listing Lambda functions..."
aws --endpoint-url=http://localhost:4566 lambda list-functions

echo "LocalStack verification complete!" 