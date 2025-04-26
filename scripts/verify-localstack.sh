#!/bin/bash

# Exit on error
set -e

echo "Checking LocalStack health (any valid JSON response)..."

for i in {1..30}; do
  response=$(curl -s http://localhost:4566/_localstack/health)
  if echo "$response" | jq . > /dev/null 2>&1; then
    echo "LocalStack /_localstack/health endpoint returned valid JSON!"
    exit 0
  fi
  echo "Waiting for valid JSON from /_localstack/health... ($i/30)"
  sleep 1
done

echo "LocalStack /_localstack/health did not return valid JSON in time."
exit 1
