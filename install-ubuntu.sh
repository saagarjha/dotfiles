#!/bin/sh

. ./shared.sh

if [ ! "$IS_ROOT" ]; then
	SUDO=sudo
else
	SUDO=
fi

ask "Install build-essential?" && $SUDO apt install build-essential
ask "Install cmake?" && $SUDO apt install cmake
ask "Install gdb?" && $SUDO apt install gdb
ask "Install clang-format?" && $SUDO apt install clang-format
ask "Install tig?" && $SUDO apt install tig
ask "Install ag?" && $SUDO apt install silversearcher-ag && checked_copy ag ~/.local/share/bash-completion/completions/ag

true
