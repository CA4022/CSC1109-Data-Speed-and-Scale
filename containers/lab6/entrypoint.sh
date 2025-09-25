#!/usr/bin/env bash

set -e

# echo "Checking if Docker daemon is running..."
# if ! docker info > /dev/null 2>&1; then
#   echo "Docker daemon is not running. Attempting to start it..."
#   dockerd &
#   echo "Waiting for Docker daemon to initialize..."
#   while ! docker info > /dev/null 2>&1; do
#       echo -n "."
#       sleep 1
#   done
#   echo "Docker daemon started successfully."
# else
#   echo "Docker daemon is already running."
# fi

echo "Running 'docker compose up'..."
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
  docker compose up "$@"
  echo "Docker Compose has been started."
else
  echo "Error: No 'docker-compose.yml' or 'docker-compose.yaml' found in the current directory."
  exit 1
fi
