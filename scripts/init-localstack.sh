#!/bin/bash

# Exit on error
set -e

echo "Initializing LocalStack resources..."

# Check if LocalStack is running
if ! nc -z localhost 4566; then
  echo "LocalStack is not running. Please start it with 'make start'"
  exit 1
fi

# Set AWS environment variables for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566

# Create DynamoDB table
echo "Creating DynamoDB table..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name Todos \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Create SQS queue
echo "Creating SQS queue..."
aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name todo-queue

# Create Dead Letter Queue
echo "Creating Dead Letter Queue..."
aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name todo-dlq

# Create SNS topic
echo "Creating SNS topic..."
aws --endpoint-url=http://localhost:4566 sns create-topic \
  --name todo-topic

# Create S3 bucket
echo "Creating S3 bucket..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://todo-dlq

# Create Lambda function
echo "Creating Lambda function..."
# First, create a zip file with the Lambda code
cd infrastructure/lambda
zip -r function.zip index.js
cd ../..

# Create the Lambda function
aws --endpoint-url=http://localhost:4566 lambda create-function \
  --function-name todo-function \
  --runtime nodejs18.x \
  --handler index.handler \
  --zip-file fileb://infrastructure/lambda/function.zip \
  --role arn:aws:iam::000000000000:role/lambda-role

# Wait for Lambda function to become active
for i in {1..30}; do
  state=$(aws --endpoint-url=http://localhost:4566 lambda get-function-configuration --function-name todo-function | jq -r '.State')
  if [[ "$state" == "Active" ]]; then
    echo "Lambda function is active!"
    break
  fi
  echo "Waiting for Lambda function to become active... ($i/30)"
  sleep 1
done

# Set environment variables for Lambda
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration \
  --function-name todo-function \
  --environment "Variables={TODO_TABLE=Todos,TODO_QUEUE_URL=http://localhost:4566/000000000000/todo-queue,TODO_TOPIC_ARN=arn:aws:sns:us-east-1:000000000000:todo-topic,TODO_BUCKET=todo-dlq}"

echo "LocalStack resources initialized successfully!" 