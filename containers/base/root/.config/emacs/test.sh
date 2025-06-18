#!/usr/bin/env bash

set -e
set -o pipefail

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: test.sh <output_file>"
  exit 1
fi

echo "Testing Emacs configuration and running tests..." >> $1
emacs --batch -l /root/.config/emacs/init.el -f ert-run-tests-batch-and-exit >> $1

echo "Emacs configuration is valid!" >> $1
