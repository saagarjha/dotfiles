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
	read -p "$1 " -r
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
		diff "$1" "$2" || { ask "$1 and $2 differ, overwrite?" || return 1; }
	fi
	if [ ! -w "$2" ]; then # TOCTOU, technically
		if ask "$2 is not writable, elevate permissions?"; then
			local COMMAND="sudo cp"
		else
			return 1;
		fi
	else
		local COMMAND="cp"
	fi
	set -x
	# echo "$COMMAND -R '$1' '$2'"
	$COMMAND -R "$1" "$2"
	{ set +x; } 2>/dev/null
}

install_stderred() {
	local SAVED_DIRECTORY="$(pwd)"
	if [ ! -w "/usr/local/stderred" ]; then
		if ask "/usr/local/stderred is not writable, elevate permissions?"; then
			cd /usr/local
			local SUDO="sudo"
		elif ask "Install locally to ~/stderred?"; then
			cd
		else
			return 1;
		fi
	fi
	if test -d stderred && ask "$(pwd)/stderred already exists, remove?"; then
		set -x
		${SUDO:-} rm -rf stderred
		{ set +x; } 2>/dev/null
	fi
	set -x
	${SUDO:-} git clone https://github.com/saagarjha/stderred.git
	cd stderred
	${SUDO:-} make
	{ set +x; } 2>/dev/null
	cd "$SAVED_DIRECTORY"
}


check_for_bash
detect_os

if [ "$HAS_BASH" ]; then
	set -o pipefail
fi

ask "Copy bashrc?" && checked_copy .bashrc ~/.bashrc
ask "Copy bash_profile?" && checked_copy .bash_profile ~/.bash_profile
ask "Copy inputrc?" && checked_copy .inputrc ~/.inputrc
ask "Copy nanorc?" && case "$OS" in
	"Mac")
		checked_copy .nanorc-mac ~/.nanorc
		;;
	"Linux"*)
		checked_copy .nanorc-linux ~/.nanorc
		;;
esac
ask "Copy clang-format?" && checked_copy .clang-format ~/.clang-format
ask "Install iTerm shell integration?" && curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
ask "Install git-ps1-status to /usr/local/bin?" && checked_copy git-ps1-status /usr/local/bin/git-ps1-status
ask "Install stderred?" && install_stderred

if [ "${LINUX:-}" = "Alpine" ]; then
	./install-alpine.sh
fi
