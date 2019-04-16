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
export HISTFILESIZE= # No limit to history file size
export HISTTIMEFORMAT="%d/%m/%y %T " # Time format for history entries
# if [[ "$TERM" == xterm* && $(command iterm-set-profile 2> /dev/null) ]]; then
# 	PROMPT_COMMAND="history -a; iterm-set-profile; printf \"\033]0;$(tty | tail -c 8 | sed 's/ttys00*/tty/g')@$(tput cols)×$(tput lines)\007\""
# fi
if [[ "$TERM" == xterm* ]]; then
	PROMPT_COMMAND="history -a; printf \"\033]0;$(tty | tail -c 8 | sed 's/ttys00*/tty/g')@$(tput cols)×$(tput lines)\007\""
fi
# export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
# export PS1="\u@\h \t \W$ "
if [[ "$BASH_VERSINFO" -ge 4 ]]; then # If a recent bash
	if [[ -x "$(which git)" && -x "$(which git-ps1-status)" ]]; then
		if [[ -x "$(which timeout)" ]]; then
			GIT_PS1_COMMAND="\[\e[35m\]\$(timeout 1 git ps1-status)\[\e[m\]"
		elif [[ -x "$(which gtimeout)" ]]; then
			GIT_PS1_COMMAND="\[\e[35m\]\$(gtimeout 1 git ps1-status)\[\e[m\]"
		else
			echo foo
		fi
	fi
	export PS1="\[\e[32m\]\u\[\e[m\] \[\e[31m\]\D{%m/%d %T}\[\e[32m\] \[\e[34m\]\W\[\e[m\]$GIT_PS1_COMMAND$ "
else
	export PS1="$USER \$(date '+%m/%d %H:%m:%S') \${PWD##*/}$ " # Backup prompt with no fancy stuff
fi
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export EDITOR=/usr/local/bin/subl
if [[ -d ~/.ssl ]]; then
	export SSL_CERT_FILE=/Users/saagarjha/.ssl/cacert.pem
fi

# If the java_home symbolic link is set, then run it to find JAVA_HOME
if [[ -L /usr/libexec/java_home ]]; then
	export JAVA_HOME="$(/usr/libexec/java_home)"
fi
export HADOOP_HOME=/usr/local/hadoop

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
alias src='source ~/.bash_profile'
function installpkg() {
	for pkg in "$@"; do
		sudo installer -pkg "$pkg" -target /
	done
}
# alias "cask-upgrade"='brew cask list | xargs brew cask install --force'
# alias "cask-upgrade"='brew cask outdated | awk "{ print $1 }" | xargs brew cask install --force'
alias swift-demangle="xcrun swift-demangle"
alias jekyll-preview="bundle exec jekyll serve --watch --safe"
alias htop="sudo htop"
alias ag="ag --color-match \"30;43\" --color-line-number \"31;31\" --color-path \"32;32\""
# if [[ $(command hub 2> /dev/null) ]]; then
# 	eval "$(hub alias -s)"
# fi
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
	export IOS_SDK_ROOT_DIR="$(dirname $(dirname $(readlink /var/db/xcode_select_link)))/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/"
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

# Make reverse-i-search use the current text, if any, as the search string.
# This makes Control-T unavailable for anything else.
# bind -r '\C-r' # Remove the default binding
# bind '"\C-t": reverse-search-history'
# bind '"\C-r": "\C-t\C-a\C-t\C-y"' # Go to the beginning of the line, start a reverse-i-search, yank the text, and start another searchs
