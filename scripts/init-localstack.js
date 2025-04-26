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

console.log('Initializing LocalStack resources...');

const initScript = process.platform === 'win32'
  ? path.join('scripts', 'init-localstack.ps1')
  : path.join('scripts', 'init-localstack.sh');

if (process.platform === 'win32') {
  executeCommand(`powershell -ExecutionPolicy Bypass -File "${initScript}"`);
} else {
  executeCommand(`bash "${initScript}"`);
} 