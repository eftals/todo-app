# Todo App

A modern todo application using AWS services, LocalStack for local development, and a cross-platform build system.

## Prerequisites

- Docker and Docker Compose
- Node.js (v18 or later)
- AWS CLI (for deployment)
- AWS CDK CLI (for deployment)

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the setup script:
   ```bash
   npm run setup
   ```

## Local Development

1. Start LocalStack:
   ```bash
   npm run start
   ```

2. Initialize LocalStack resources:
   ```bash
   npm run init-localstack
   ```

3. Run tests:
   ```bash
   npm run test
   ```

## Deployment

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Deploy to AWS:
   ```bash
   npm run deploy
   ```

## Project Structure

- `backend/` - ASP.NET backend service code
- `frontend/` - React frontend application code
- `infrastructure/` - AWS CDK infrastructure code
- `scripts/` - Cross-platform utility scripts
- `volume/` - LocalStack data directory

## Available Commands

- `npm run setup` - Set up the development environment
- `npm run start` - Start LocalStack
- `npm run stop` - Stop LocalStack
- `npm run clean` - Clean up resources
- `npm run test` - Run tests
- `npm run deploy` - Deploy to AWS
- `npm run init-localstack` - Initialize LocalStack resources

## LocalStack Resources

The following AWS resources are available in LocalStack:

- DynamoDB Table: `Todos`
- SQS Queue: `todo-queue`
- SNS Topic: `todo-topic`
- S3 Bucket: `todo-dlq`
- Lambda Function: `todo-function`

## Cross-Platform Support

This project uses a cross-platform build system that works on:
- Windows
- Linux
- macOS

The build system automatically detects your operating system and uses the appropriate scripts.

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests
4. Submit a pull request

## License

MIT 