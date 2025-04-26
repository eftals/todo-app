const { execSync } = require('child_process');

function executeCommand(command) {
  try {
    execSync(command, { stdio: 'inherit' });
  } catch (error) {
    console.error(`Error executing command: ${command}`);
    console.error(error.message);
    process.exit(1);
  }
}

console.log('Stopping LocalStack...');
executeCommand('docker-compose down');
console.log('LocalStack stopped.'); 