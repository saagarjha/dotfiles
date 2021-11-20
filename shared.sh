#!/bin/sh

ask() {
	printf "%s " "$1"
	read -r reply
	case "$reply" in
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
		if [ -e "$2" ]; then
			echo "$2 already linked, skipping..." && return 0;
		else
			if ! ask "$2 is a broken link, remove it?"; then
				return 0;
			fi
		fi
	fi
	if [ -f "$2" ]; then
		cmp -s "$1" "$2" || { diff "$1" "$2" || true && ask "$1 and $2 differ, overwrite?" || return 1; }
	fi
	# TOCTOU, what's that?
	if ! touch "$2"; then
		if ask "$2 is not writable, elevate permissions?"; then
			command_rm="sudo rm"
			command_ln="sudo ln"
		else
			return 1;
		fi
	else
		command_rm="rm"
		command_ln="ln"
	fi
	set -x
	$command_rm -r "$2"
	$command_ln -s "$PWD/$1" "$2"
	{ set +x; } 2>/dev/null
}
