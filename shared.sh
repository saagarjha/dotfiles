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

checked_copy() {
	if [ -f "$2" ]; then
		cmp -s "$1" "$2" || { diff "$1" "$2" || true && ask "$1 and $2 differ, overwrite?" || return 1; }
	fi
	if [ touch "$2" ]; then
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
