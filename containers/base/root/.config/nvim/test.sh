#!/usr/bin/env bash

set -e
set -o pipefail

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: test.sh <output_file>"
  exit 1
fi

echo "Testing Neovim configuration..." >> $1
nvim --headless -u /root/.config/nvim/init.lua +q >> $1

echo "Neovim configuration is valid!" >> $1
