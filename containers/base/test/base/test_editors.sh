#!/usr/bin/env bash

set -e
set -o pipefail

echo "Testing micro settings..."
jq empty /root/.config/micro/settings.json

echo "Testing Neovim configuration..."
nvim --headless -u /root/.config/nvim/init.lua +q

echo "Testing Emacs configuration and running tests..."
emacs --batch -l /root/.config/emacs/init.el -f ert-run-tests-batch-and-exit

echo "All configurations are valid!"
