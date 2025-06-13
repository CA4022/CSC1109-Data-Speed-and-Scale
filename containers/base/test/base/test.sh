#! /usr/bin/env bash

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: ./base/test.sh <output_file>"
  exit 1
fi

cd /test/base/

echo "Computing system hash..."
./system_hash.sh $1
echo "Testing editor configurations..."
./test_editors.sh &> $1
