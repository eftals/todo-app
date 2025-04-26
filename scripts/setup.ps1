# Setup script for Windows
Write-Host "Setting up development environment..."

# Install required tools if not present
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker Desktop for Windows first."
    exit 1
}

if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not installed. Please install Docker Desktop for Windows first."
    exit 1
}

# Check for .NET SDK
if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host ".NET SDK is not installed. Please install .NET 8.0 SDK first."
    exit 1
}

# Verify .NET SDK version
$dotnetVersion = dotnet --version
if ($dotnetVersion -notmatch "^8\.") {
    Write-Host "This project requires .NET 8.0 SDK. Current version: $dotnetVersion"
    exit 1
}

# Install Pants
Write-Host "Installing Pants build system..."
Invoke-WebRequest -Uri "https://static.pantsbuild.org/setup/get-pants.sh" -OutFile "get-pants.sh"
bash get-pants.sh
# Note: On Windows, the pants script will be executed through Python

# Create necessary directories
New-Item -ItemType Directory -Force -Path "volume"
New-Item -ItemType Directory -Force -Path "volume/localstack"

# Install Node.js dependencies
Write-Host "Installing Node.js dependencies..."
npm install

# Restore .NET dependencies
Write-Host "Restoring .NET dependencies..."
dotnet restore backend/backend.csproj

Write-Host "Setup completed successfully!" 