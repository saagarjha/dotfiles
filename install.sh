#!/bin/sh

ln -s "$(pwd)" ~/.dotfiles
cd ~/.dotfiles
yes | ./_install.sh
