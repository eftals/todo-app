# scripts/init-localstack.ps1

Write-Host "Initializing LocalStack resources..."

# Check if LocalStack is running
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect("localhost", 4566)
    $tcpClient.Close()
} catch {
    Write-Host "LocalStack is not running. Please start it with 'npm run start'"
    exit 1
}

# Set AWS environment variables for LocalStack
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "us-east-1"
$env:AWS_ENDPOINT_URL = "http://localhost:4566"

# Create DynamoDB table
Write-Host "Creating DynamoDB table..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table `
  --table-name Todos `
  --attribute-definitions AttributeName=id,AttributeType=S `
  --key-schema AttributeName=id,KeyType=HASH `
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Create SQS queue
Write-Host "Creating SQS queue..."
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name todo-queue

# Create Dead Letter Queue
Write-Host "Creating Dead Letter Queue..."
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name todo-dlq

# Create SNS topic
Write-Host "Creating SNS topic..."
aws --endpoint-url=http://localhost:4566 sns create-topic --name todo-topic

# Create S3 bucket
Write-Host "Creating S3 bucket..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://todo-dlq

# Create Lambda function
Write-Host "Creating Lambda function..."
Push-Location infrastructure/lambda
Compress-Archive -Path index.js -DestinationPath function.zip -Force
Pop-Location

aws --endpoint-url=http://localhost:4566 lambda create-function `
  --function-name todo-function `
  --runtime nodejs18.x `
  --handler index.handler `
  --zip-file fileb://infrastructure/lambda/function.zip `
  --role arn:aws:iam::000000000000:role/lambda-role

# Set environment variables for Lambda
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration `
  --function-name todo-function `
  --environment "Variables={TODO_TABLE=Todos,TODO_QUEUE_URL=http://localhost:4566/000000000000/todo-queue,TODO_TOPIC_ARN=arn:aws:sns:us-east-1:000000000000:todo-topic,TODO_BUCKET=todo-dlq}"

Write-Host "LocalStack resources initialized successfully!" 