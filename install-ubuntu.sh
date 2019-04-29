#!/bin/sh

. ./shared.sh

if [ ! "$IS_ROOT" ]; then
	SUDO=sudo
else
	SUDO=
fi

ask "Install cmake?" && $SUDO apt install cmake

set -x

gsettings set io.elementary.terminal.settings natural-copy-paste false

gsettings set org.pantheon.desktop.gala.appearance button-layout close,minimize,maximize

{ set +x; } 2>/dev/null

true
