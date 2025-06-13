#! /usr/bin/env bash

cd /test/

echo "Testing all container configuration layers..."

for test_script in ./*/test.sh; do
  if [ -f "$test_script" ]; then
    echo "Running $test_script..."
    "$test_script" /tmp/test_results.txt
  fi
done

echo "All tests complete."

