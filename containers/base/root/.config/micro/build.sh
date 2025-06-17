#!/usr/bin/env bash

# Install micro
zypper --non-interactive addrepo https://download.opensuse.org/repositories/devel:languages:go/${BASE_OPENSUSE_VERSION}/devel:languages:go.repo
zypper --non-interactive --gpg-auto-import-keys refresh
zypper --non-interactive install micro-editor
zypper clean --all # cleanup
cd /root/.config/micro
# Install color themes
mkdir colorschemes
git clone https://github.com/catppuccin/micro catppuccin
cd catppuccin
git checkout 2802b32
cp src/* ../colorschemes/
cd ..
rm -r catppuccin
# Install plugins
micro -plugin install filemanager lsp autofmt detectindent fzf jump bounce cheat
