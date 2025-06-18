#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: test.sh <output_file>"
  exit 1
fi

echo "Bat: no tests needed!" >> $1
