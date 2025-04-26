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

const verifyInitScript = process.platform === 'win32'
  ? path.join('scripts', 'verify-localstack-init.ps1')
  : path.join('scripts', 'verify-localstack-init.sh');

if (process.platform === 'win32') {
  executeCommand(`powershell -ExecutionPolicy Bypass -File "${verifyInitScript}"`);
} else {
  executeCommand(`bash "${verifyInitScript}"`);
} 