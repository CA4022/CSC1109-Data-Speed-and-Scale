#!/bin/bash
set -e

dockerd &> /var/log/dockerd.log &

while ! docker info &> /dev/null; do
  echo "Waiting for dockerd..."
  sleep 1
done

exec "$@"
