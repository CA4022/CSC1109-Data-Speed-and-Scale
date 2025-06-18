#! /usr/bin/env bash

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: ./base/test.sh <output_file>"
  exit 1
fi

cd "$(dirname "$0")"

echo "Testing all container configuration layers..." >> $1

for test_script in ./*/test.sh; do
  if [ -f "$test_script" ]; then
    echo "Running $test_script..." >> $1
    $test_script >> $1
  fi
done

echo "All tests complete." >> $1

