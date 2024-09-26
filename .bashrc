shopt -s histappend
if [[ "$BASH_VERSINFO" -ge 4 ]]; then
	shopt -s globstar
fi

if [[ -t 1 ]]; then # Check if standard out is a terminal
	# Disable default Control-S so it can be used for forward search
	stty -ixon
fi

export HISTFILE=~/.bash_history_noclobber # Avoid bash from clobbering history if we don't set any variables
export HISTSIZE= # No limit to history size
export GDBHISTSIZE= # No limit to GDB history size
export HISTFILESIZE= # No limit to history file size
export HISTTIMEFORMAT="%d/%m/%y %T " # Time format for history entries
if [[ -z ${SET_PROMPT_COMMAND+x} ]]; then
	if [[ "$TERM" == xterm* && "$TERM_PROGRAM" == iTerm.app ]]; then
		# \303\227 is the multiplication sign, since the literal character doesn't work
		PROMPT_COMMAND='history -a; printf "\033]0;$(tty | sed "s#/dev/\([^0]*\)0*\([0-9]*\)#\1\2#")@$COLUMNS\303\227$LINES\007"'
	else
		PROMPT_COMMAND="history -a"
	fi
fi
export SET_PROMPT_COMMAND=1
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
	PS1="$PS1_HOSTNAME \$(date '+%m/%d %H:%m:%S') \${PWD##*/}$ " # Backup prompt with no fancy stuff
fi
export CLICOLOR=1
export LSCOLORS=exFxCxDxBxegedabagacad
export LS_COLORS="di=34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
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
function dyld_hopper() {
	local dylib_dir="$(mktemp -d)" && \
	dyld_shared_cache_util -extract_matching "$1" "$dylib_dir" "$(find /System/Library/dyld | fzy)" && \
	hopper "$(find "$dylib_dir" -type f | fzy)"
}
alias ghidra='java -cp /Applications/Ghidra.app/Contents/Resources/ OpenGhidra'
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
function ag() {
	command ag --mmap --color-match "30;43" --color-line-number "31;31" --color-path "32;32" --color "$@" | cut -c1-1000
}
alias more="less" # Sorry, Mark Nudelman!
function gnutils() { # Use GNU tools over the system-provided BSD ones
	export PATH="/opt/local/libexec/gnubin:$PATH"
}
if [[ -L /var/select/developer_dir ]]; then
	alias xcopen="open -a \$(dirname $(dirname $(readlink /var/select/developer_dir)))"
	export MACOS_SDK="$(dirname $(dirname $(readlink /var/select/developer_dir)))/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
	ios_build="$(xcrun simctl runtime match list -j | jq 'to_entries[] | if (.key | test("iphoneos")) then .value.preferredBuild else empty end')"
	mount_path="$(xcrun simctl runtime list -j | jq -r ".[] | if (.build == $ios_build) then .mountPath else empty end")"
	ios_version="$(xcrun simctl runtime list -j | jq -r ".[] | if (.build == $ios_build) then .version else empty end")"
	export IOS_SDK="$mount_path/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS $ios_version.simruntime/Contents/Resources/RuntimeRoot/"
fi
export DYLD_CRYPTEX=/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld
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

swift() {
	if [ $# -eq 0 ]; then
		command swift repl
	else
		command swift "$@"
	fi
}

function cd() {
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
