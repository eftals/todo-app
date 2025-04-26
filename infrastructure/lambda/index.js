const AWS = require('aws-sdk');

// Configure AWS SDK for LocalStack
const isLocalStack = process.env.AWS_ENDPOINT_URL || process.env.LOCALSTACK_HOSTNAME;
if (isLocalStack) {
  AWS.config.update({
    endpoint: process.env.AWS_ENDPOINT_URL || `http://${process.env.LOCALSTACK_HOSTNAME}:4566`,
    region: process.env.AWS_DEFAULT_REGION || 'us-east-1',
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test',
    },
  });
}

// Initialize AWS services
const dynamodb = new AWS.DynamoDB.DocumentClient();
const sqs = new AWS.SQS();
const sns = new AWS.SNS();
const s3 = new AWS.S3();

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  try {
    // Example: Store a todo item in DynamoDB
    const todoItem = {
      id: Date.now().toString(),
      title: 'Test Todo',
      completed: false,
      createdAt: new Date().toISOString(),
    };

    await dynamodb.put({
      TableName: process.env.TODO_TABLE,
      Item: todoItem,
    }).promise();

    // Example: Send a message to SQS
    await sqs.sendMessage({
      QueueUrl: process.env.TODO_QUEUE_URL,
      MessageBody: JSON.stringify(todoItem),
    }).promise();

    // Example: Publish to SNS
    await sns.publish({
      TopicArn: process.env.TODO_TOPIC_ARN,
      Message: JSON.stringify(todoItem),
    }).promise();

    // Example: Upload to S3
    await s3.putObject({
      Bucket: process.env.TODO_BUCKET,
      Key: `${todoItem.id}.json`,
      Body: JSON.stringify(todoItem),
    }).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Todo created successfully',
        todo: todoItem,
      }),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Error creating todo',
        error: error.message,
      }),
    };
  }
}; 