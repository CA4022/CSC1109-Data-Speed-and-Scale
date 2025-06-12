#!/usr/bin/env bash

# Install neovim from tarball (SUSE Leap version is woefully out of date)
mkdir /nvim
cd /nvim
wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
tar xf nvim-linux-x86_64.tar.gz
cp -r nvim-linux-x86_64/* /
rm -r /nvim
