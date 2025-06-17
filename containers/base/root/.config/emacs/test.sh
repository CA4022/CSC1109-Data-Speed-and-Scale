#!/usr/bin/env bash

set -e
set -o pipefail

echo "Testing Emacs configuration and running tests..."
emacs --batch -l /root/.config/emacs/init.el -f ert-run-tests-batch-and-exit

echo "Emacs configuration is valid!"
