import * as cdk from 'aws-cdk-lib';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as s3 from 'aws-cdk-lib/aws-s3';
import { Construct } from 'constructs';
import * as fs from 'fs';
import * as path from 'path';

export class TodoStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Load table schema from JSON
    const schemaPath = path.join(__dirname, '..', 'todo-table-schema.json');
    const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf-8'));

    // DynamoDB table
    const todoTable = new dynamodb.Table(this, 'TodoTable', {
      tableName: schema.TableName,
      partitionKey: { name: 'username', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'date', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // SQS queue
    const todoQueue = new sqs.Queue(this, 'TodoQueue', {
      visibilityTimeout: cdk.Duration.seconds(300),
    });

    // Dead Letter Queue
    const dlq = new sqs.Queue(this, 'TodoDLQ', {
      visibilityTimeout: cdk.Duration.seconds(300),
    });

    // SNS topic
    const todoTopic = new sns.Topic(this, 'TodoTopic');

    // S3 bucket for file storage
    const todoBucket = new s3.Bucket(this, 'TodoBucket', {
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    // Lambda function
    const todoLambda = new lambda.Function(this, 'TodoFunction', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('lambda'),
      environment: {
        TODO_TABLE: todoTable.tableName,
        TODO_QUEUE_URL: todoQueue.queueUrl,
        TODO_TOPIC_ARN: todoTopic.topicArn,
        TODO_BUCKET: todoBucket.bucketName,
      },
    });

    // Grant permissions
    todoTable.grantReadWriteData(todoLambda);
    todoQueue.grantSendMessages(todoLambda);
    todoTopic.grantPublish(todoLambda);
    todoBucket.grantReadWrite(todoLambda);
  }
} 