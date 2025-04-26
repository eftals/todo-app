#!/bin/bash

set -e

REQUIRED_SERVICES=(dynamodb sqs sns s3 lambda)

for i in {1..30}; do
  response=$(curl -s http://localhost:4566/health)
  all_running=true
  for service in "${REQUIRED_SERVICES[@]}"; do
    status=$(echo "$response" | jq -r ".services.$service")
    if [[ "$status" != "running" ]]; then
      all_running=false
      break
    fi
  done
  if $all_running; then
    echo "All required LocalStack services are running!"
    exit 0
  fi
  echo "Waiting for all services to be running... ($i/30)"
  sleep 1
done

echo "Not all required LocalStack services became running in time."
exit 1 