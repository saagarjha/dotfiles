#!/bin/sh

if [ "${BASH_VERSION:-}" ]; then
	HAS_BASH=1
else
	HAS_BASH=
fi

case "$(uname)" in
	"Darwin")
		OS=Mac
		;;
	"Linux")
		OS=Linux
		;;
esac

set -eux
if [ "$HAS_BASH" ]; then
	set -o pipefail
fi

checked_copy() {
	if [ -f "$2" ]; then
		diff "$1" "$2" || { echo "$1 and $2 differ, stopping" && exit 1; }
	fi
	cp -R "$1" "$2"
}

checked_copy .bashrc ~/.bashrc
checked_copy .bash_profile ~/.bash_profile
checked_copy .inputrc ~/.inputrc
if [ "$OS" = "Mac" ]; then
	checked_copy .nanorc-mac ~/.nanorc
elif [ "$OS" = "Linux" ]; then
	checked_copy .nanorc-linux ~/.nanorc
fi
checked_copy .clang-format ~/.clang-format

checked_copy git-ps1-status /usr/local/bin/git-ps1-status
