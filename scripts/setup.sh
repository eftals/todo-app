#!/bin/bash

# Setup script for Linux/macOS
echo "Setting up development environment..."

# Check for required tools
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check for .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo ".NET SDK is not installed. Please install .NET 8.0 SDK first."
    exit 1
fi

# Verify .NET SDK version
DOTNET_VERSION=$(dotnet --version)
if [[ ! $DOTNET_VERSION =~ ^8\. ]]; then
    echo "This project requires .NET 8.0 SDK. Current version: $DOTNET_VERSION"
    exit 1
fi

# Install Pants
echo "Installing Pants build system..."
curl --proto '=https' --tlsv1.2 -fsSL https://static.pantsbuild.org/setup/get-pants.sh | bash

# Create necessary directories
mkdir -p volume/localstack

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

# Restore .NET dependencies
echo "Restoring .NET dependencies..."
dotnet restore backend/backend.csproj

echo "Setup completed successfully!" 