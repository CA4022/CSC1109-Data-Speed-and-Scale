#!/usr/bin/env bash

zypper --non-interactive install emacs
emacs --batch -l ~/.config/emacs/init.el # Pre-install emacs plugins
