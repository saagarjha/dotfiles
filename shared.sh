#!/bin/sh

ask() {
	printf "$1 "
	read -r REPLY
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

# TODO rewrite this in C because POSIX sucks
checked_copy() {
	if [ -L "$2" ]; then
		echo "$2 already linked, skipping..." && return 0;
	fi
	if [ -f "$2" ]; then
		cmp -s "$1" "$2" || { diff "$1" "$2" || true && ask "$1 and $2 differ, overwrite?" || return 1; }
	fi
	# TOCTOU, what's that?
	if ! touch "$2"; then
		if ask "$2 is not writable, elevate permissions?"; then
			local COMMAND_RM="sudo rm"
			local COMMAND_LN="sudo ln"
		else
			return 1;
		fi
	else
		local COMMAND_RM="rm"
		local COMMAND_LN="ln"
	fi
	set -x
	$COMMAND_RM "$2"
	$COMMAND_LN -s "$PWD/$1" "$2"
	{ set +x; } 2>/dev/null
}
