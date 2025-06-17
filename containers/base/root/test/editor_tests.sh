#!/usr/bin/env bash

set -e
set -o pipefail

echo "Testing editor configurations..."

for test_script in ./editor_tests/*.sh; do
  if [ -f "$test_script" ]; then
    echo "Running $test_script..."
    $test_script
  fi
done

echo "All configurations are valid!"
