#!/bin/sh

set -eux
if [ "${BASH_VERSION:-}" ]; then
	set -o pipefail
fi

checked_copy() {
	if [ -f "$2/$1" ]; then
		diff "$1" "$2/$1" || { echo "$1 and $2 differ, stopping" && exit 1; }
	fi
	cp "$1" "$2"
}

checked_copy .bashrc ~
checked_copy .bash_profile ~
checked_copy .inputrc ~
checked_copy .nanorc ~
checked_copy .clang-format ~
