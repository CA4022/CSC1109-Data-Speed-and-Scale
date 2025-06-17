#!/usr/bin/env bash

set -e
set -o pipefail

echo "Testing Neovim configuration..."
nvim --headless -u /root/.config/nvim/init.lua +q

echo "Neovim configuration is valid!"
