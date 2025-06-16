#!/usr/bin/env bash

# Install neovim from tarball (SUSE Leap version is woefully out of date)
mkdir /nvim
cd /nvim
wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
tar xf nvim-linux-x86_64.tar.gz
cp -r nvim-linux-x86_64/* /
rm -r /nvim
# Install neovim plugins at container build time
# First: bootstrap lazy.nvim using luarocks
zypper --non-interactive install lua53 lua53-devel unzip
wget https://luarocks.org/releases/luarocks-3.12.0.tar.gz
tar zxpf luarocks-3.12.0.tar.gz
cd luarocks-3.12.0
./configure && make && make install
cd ..
rm -r luarocks-3.12.0
luarocks install lazy.nvim
# Then, headlessly bootstrap the neovim setup
curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua | nvim --headless +qa -c -
