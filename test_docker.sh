#!/bin/bash
set -e

# Build the Docker image using the provided Dockerfile
docker build -t test-hello-app .

# Run the container in detached mode mapping port 3000 to the host
container_id=$(docker run -d -p 3000:3000 test-hello-app)

# Wait a few seconds for the Rails server to start
sleep 10

# Get the response from the application endpoint
response=$(curl -s http://localhost:3000/)

# Check if the response is as expected
if [ "$response" == "Hello World v2.1" ]; then
  echo "Docker test passed: Received expected response."
  docker rm -f "$container_id"
  exit 0
else
  echo "Docker test failed: Unexpected response: $response"
  docker logs "$container_id"
  docker rm -f "$container_id"
  exit 1
fi


