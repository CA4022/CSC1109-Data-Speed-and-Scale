#! /usr/bin/env bash

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: test.sh <output_file>"
  exit 1
fi

cd "$(dirname "$0")"

echo "Testing editor configurations..."
./editor_tests.sh $1
