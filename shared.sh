#!/bin/sh

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