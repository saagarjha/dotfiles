shopt -s histappend
if [[ "$BASH_VERSINFO" -ge 4 ]]; then
	shopt -s globstar
	shopt -s autocd
fi

if [[ -t 1 ]]; then # Check if standard out is a terminal
	# Disable default Control-S so it can be used for forward search
	stty -ixon
fi

export HISTSIZE= # No limit to history size
export GDBHISTSIZE= # No limit to GDB history size
export HISTFILESIZE= # No limit to history file size
export HISTTIMEFORMAT="%d/%m/%y %T " # Time format for history entries
if [[ "$TERM" == xterm* && -x "$(which tput 2> /dev/null)" && ! "$SET_PROMPT_COMMAND" ]]; then
	PROMPT_COMMAND="history -a; printf \"\033]0;$(tty | sed 's#/dev/\([^0]*\)0*\([0-9]*\)#\1\2#')@$(tput cols)×$(tput lines)\007\""
	export SET_PROMPT_COMMAND=1
fi
if [[ "$BASH_VERSINFO" -ge 4 ]]; then # If a recent bash
	if [[ -x "$(which git 2> /dev/null)" && -x "$(which git-ps1-status 2> /dev/null)" ]]; then
		if [[ -x "$(which timeout 2> /dev/null)" ]]; then
			if "$(which timeout 2> /dev/null)" 2>&1 | grep -q BusyBox; then
				PS1_GIT_COMMAND="\[\e[35m\]\$(timeout -t 1 git ps1-status)\[\e[m\]"
			else
				PS1_GIT_COMMAND="\[\e[35m\]\$(timeout 1 git ps1-status)\[\e[m\]"
			fi
		elif [[ -x "$(which gtimeout 2> /dev/null)" ]]; then
			PS1_GIT_COMMAND="\[\e[35m\]\$(gtimeout 1 git ps1-status)\[\e[m\]"
		fi
	fi

	if [ "$SSH_TTY" ]; then
		PS1_HOSTNAME="\u@\h"
	else
		PS1_HOSTNAME="\u"
	fi
	PS1="\[\e[32m\]$PS1_HOSTNAME\[\e[m\] \[\e[31m\]\D{%m/%d %T}\[\e[32m\] \[\e[34m\]\W\[\e[m\]$PS1_GIT_COMMAND\\$ "
else
	if [ "$SSH_TTY" ]; then
		PS1_HOSTNAME="$USER@$HOSTNAME"
	else
		PS1_HOSTNAME="$USER"
	fi
	PS1="$HOSTNAME \$(date '+%m/%d %H:%m:%S') \${PWD##*/}$ " # Backup prompt with no fancy stuff
fi
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
if [[ -x "$(which dircolors 2> /dev/null)" ]]; then
	eval "$(dircolors -b)"
	export LS_OPTIONS="--color=auto"
fi
alias ls="ls $LS_OPTIONS"
export EDITOR="$(which nano)"
if [[ -d ~/.ssl ]]; then
	export SSL_CERT_FILE=/Users/saagarjha/.ssl/cacert.pem
fi

alias wolfram='/Applications/Mathematica.app/Contents/MacOS/WolframKernel'
alias hdstart='start-dfs.sh && start-yarn.sh'
alias hdstop='stop-dfs.sh && stop-yarn.sh'
alias hdrestart='hdstop && hdstart'
alias hdrm='hdfs dfs -rm -r /user/saagarjha/output'
function hdc() {
	hadoop com.sun.tools.javac.Main $1.java ${@:2}
}
function hdj() {
	jar cf $1.jar $1*.class
}
function hdr {
	hadoop jar $1.jar ${@:2}
}
function hd {
	hdrm; hdc $1 && hdj $1 && hdr $@
}
alias tigcc='tigcc -Os'
alias hopperv3='/usr/local/bin/hopper -e'
# alias hopper='hopperv4 -e'
function hopper() {
	local dil="$DYLD_INSERT_LIBRARIES"
	unset DYLD_INSERT_LIBRARIES
	hopperv4 -e "$@"
	export DYLD_INSERT_LIBRARIES="$dil"
}
function appbundleid() {
	/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$1/Contents/Info.plist"
}
alias src='. ~/.bash_profile'
function installpkg() {
	for pkg in "$@"; do
		sudo installer -pkg "$pkg" -target /
	done
}
alias swift-demangle="xcrun swift-demangle"
alias jekyll-preview="bundle exec jekyll serve --watch --safe"
alias htop="sudo htop"
alias ag="ag --color-match \"30;43\" --color-line-number \"31;31\" --color-path \"32;32\""
alias more="less" # Sorry, Mark Nudelman!
function gnutils() { # Use GNU tools over the system-provided BSD ones
	export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
	export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
	export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
	export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
	export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
}
if [[ -L /var/db/xcode_select_link ]]; then
	alias xcopen="open -a \$(dirname $(dirname $(readlink /var/db/xcode_select_link)))"
	export IOS_SDK="$(dirname $(dirname $(readlink /var/db/xcode_select_link)))/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/"
	export MACOS_SDK="$(dirname $(dirname $(readlink /var/db/xcode_select_link)))/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/"
fi
alias xcbopen="open -a Xcode-beta"
alias xc-open="open -a Xcode"
function adb-paste() {
	adb shell "am startservice ca.zgrs.clipper/.ClipboardService && am broadcast -a clipper.set -e text '$1'"
}
alias spim="spim -f"
alias sysdiagnose="sudo sysdiagnose -v"
function xed() {
	if [[ $# == 1 ]]; then
		command xed "$1"
	else
		xed "$PWD"
	fi
}
function gitup() {
	(
		cd "$1"
		command gitup
	)
}
function macports() {
	cat <(echo "macOS $(sw_vers -productVersion) $(sw_vers -buildVersion)") <(echo "Xcode $(xcodebuild -version | awk '{print $NF}' | tr '\n' ' ')") | pbcopy
}

cd() {
	# Set the current directory to the 0th history item
	cd_history[0]=$PWD
	if [[ $1 == -h ]]; then
		for i in ${!cd_history[@]}; do
			echo $i: "${cd_history[$i]}"
		done
		return
	elif [[ $1 =~ ^-[0-9]+ ]]; then
		builtin cd "${cd_history[${1//-}]}" || # Remove the argument's dash
		return
	else
		builtin cd "$@" || return # Bail if cd fails
	fi
	# cd_history = ["", $OLDPWD, cd_history[1:]]
	cd_history=("" "$OLDPWD" "${cd_history[@]:1:${#cd_history[@]}}")
}
