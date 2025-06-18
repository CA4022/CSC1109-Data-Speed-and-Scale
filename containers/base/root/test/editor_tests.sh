#!/usr/bin/env bash

set -e
set -o pipefail

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: ./base/editor_tests.sh <output_file>"
  exit 1
fi

echo "Testing editor configurations..." >> $1

for test_script in ./editor_tests/*.sh; do
  if [ -f "$test_script" ]; then
    echo "Running $test_script..." >> $1
    $test_script $1
  fi
done

echo "All configurations are valid!" >> $1
