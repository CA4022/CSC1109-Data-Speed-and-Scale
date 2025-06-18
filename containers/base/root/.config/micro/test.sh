#!/usr/bin/env bash

set -e
set -o pipefail

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: test.sh <output_file>"
  exit 1
fi

echo "Testing micro settings..." >> $1
jq empty /root/.config/micro/settings.json

echo "Micro configuration is valid!" >> $1
