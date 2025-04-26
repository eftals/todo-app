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

console.log('Setting up development environment...');

// Execute setup script
const setupScript = process.platform === 'win32'
  ? path.join('scripts', 'setup.ps1')
  : path.join('scripts', 'setup.sh');

if (process.platform === 'win32') {
  // Run PowerShell script directly
  executeCommand(`powershell -ExecutionPolicy Bypass -File "${setupScript}"`);
} else {
  // Run Bash script directly
  executeCommand(`bash "${setupScript}"`);
} 