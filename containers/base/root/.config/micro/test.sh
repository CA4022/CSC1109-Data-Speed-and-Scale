#!/usr/bin/env bash

set -e
set -o pipefail

echo "Testing micro settings..."
jq empty /root/.config/micro/settings.json

echo "Micro configuration is valid!"
