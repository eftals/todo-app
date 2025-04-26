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

# Install Pants
echo "Installing Pants build system..."
curl --proto '=https' --tlsv1.2 -fsSL https://static.pantsbuild.org/setup/get-pants.sh | bash

# Create necessary directories
mkdir -p volume/localstack

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

echo "Setup completed successfully!" 