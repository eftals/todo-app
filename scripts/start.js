const { execSync } = require('child_process');
const path = require('path');

function executeCommand(command) {
  try {
    execSync(command, { stdio: 'inherit' });
  } catch (error) {
    console.error(`Error executing command: ${command}`);
    console.error(error.message);
    process.exit(1);
  }
}

console.log('Starting LocalStack...');

// Start LocalStack using docker-compose
executeCommand('docker-compose up -d localstack');

console.log('Waiting for LocalStack to be ready...');

// Execute basic health verification script
const verifyScript = process.platform === 'win32'
  ? path.join('scripts', 'verify-localstack.ps1')
  : path.join('scripts', 'verify-localstack.sh');

if (process.platform === 'win32') {
  executeCommand(`powershell -ExecutionPolicy Bypass -File "${verifyScript}"`);
} else {
  executeCommand(`bash "${verifyScript}"`);
} 