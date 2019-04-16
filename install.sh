#!/bin/sh

set -eu

check_for_bash() {
	printf "Looking for Bash..."
	if [ "${BASH_VERSION:-}" ]; then
		export HAS_BASH=1
		echo "found $BASH_VERSION"
	else
		export HAS_BASH=
		echo "not found"
	fi
}

detect_os() {
	printf "Detecting OS..."
	case "$(uname)" in
		"Darwin")
			export OS=macOS
			;;
		"Linux")
			export OS=Linux
			case "$(uname -a)" in
				*Ubuntu*)
					export OS="$OS Ubuntu"
					;;
				*Alpine*)
					export OS="$OS Alpine"
					;;
				*)
					OS=Linux
					;;
			esac
			;;
	esac
	echo "$OS"
}

ask() {
	read -p "$1 " -n 1 -r
	echo
	case "$REPLY" in
		"Y")
			return 0
			;;
		"y")
			return 0
			;;
		*)
			return 1
			;;
	esac
}

checked_copy() {
	if [ -f "$2" ]; then
		diff "$1" "$2" || { echo "$1 and $2 differ, stopping" && exit 1; }
	fi
	if [ "$#" -eq 2 ]; then
		cp -R "$1" "$2"
	elif [ "$#" -eq 3 ]; then
		sudo cp -R "$1" "$2"
	fi
}


check_for_bash
detect_os

if [ "$HAS_BASH" ]; then
	set -o pipefail
fi

if ask "Copy bashrc?"; then
	checked_copy .bashrc ~/.bashrc
fi

if ask "Copy bash_profile?"; then
	checked_copy .bash_profile ~/.bash_profile
fi

if ask "Copy inputrc?"; then
	checked_copy .inputrc ~/.inputrc
fi

if ask "Copy nanorc?"; then
	if [ "$OS" = "Mac" ]; then
		checked_copy .nanorc-mac ~/.nanorc
	elif [ "$OS" =~ "^Linux" ]; then
		checked_copy .nanorc-linux ~/.nanorc
	fi
fi

if ask "Copy clang-format?"; then
	checked_copy .clang-format ~/.clang-format
fi

if ask "Install iTerm shell integration?"; then
	curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
fi

if ask "Install git-ps1-status to /usr/local/bin?"; then
	checked_copy git-ps1-status /usr/local/bin/git-ps1-status sudo
fi

if [ "${LINUX:-}" = "Alpine" ]; then
	./install-alpine.sh
fi
