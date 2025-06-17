#!/usr/bin/env bash

zypper --non-interactive install emacs
zypper clean --all # cleanup
emacs --batch -l ~/.config/emacs/init.el # Pre-install emacs plugins
