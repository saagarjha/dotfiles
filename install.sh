#!/bin/sh

set -euxo pipefail

checked_copy() {
	diff "$1" "$2" || "$1 and $2 differ, stopping" && exit 1
	cp "$1" "$2"
}

checked_copy(".bashrc", "~/.bashrc")
checked_copy(".bash_profile", "~/.bash_profile")
checked_copy(".inputrc", "~/.inputrc")
checked_copy(".nanorc", "~/.nanorc")
checked_copy(".clang-format", "~/.clang-format")
