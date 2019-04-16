# MacPorts, so .bashrc can see commands
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

source ~/.bashrc

if [[ -f ~/.tokens ]]; then
	source ~/.tokens
fi

if [[ -f ~/.fzy && -t 1 ]]; then
	source ~/.fzy
fi

if [[ "$BASH_VERSINFO" -ge 4 ]]; then
# 	if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
# 	   . $(brew --prefix)/share/bash-completion/bash_completion
# 	fi
	if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
		. /opt/local/etc/profile.d/bash_completion.sh
	fi
fi

export CFLAGS="-I/opt/local/include"
export CPPFLAGS="-I/opt/local/include"
export CXXFLAGS="-I/opt/local/include"
export LDFLAGS="-L/opt/local/lib"

# pip
export PATH="$PATH:~/Library/Python/2.7/bin/"
export PATH="$PATH:~/Library/Python/3.7/bin/"

# Ruby
export GEM_HOME="$(ls -t -U | ruby -e 'puts Gem.user_dir')"
export GEM_PATH="$GEM_HOME"
export PATH="$PATH:$GEM_HOME/bin"

export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Users/saagarjha/android-sdks/platform-tools"
export PATH="$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"

launchctl setenv PATH $PATH

if [[ "$TERM" == xterm* ]]; then
	test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
fi

export TIGCC="/usr/local/tigcc"
export PATH="$PATH:$TIGCC/bin"

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"

# stderred
if [[ -f /usr/local/stderred/build/libstderred.dylib ]]; then
	# export DYLD_INSERT_LIBRARIES=
	export DYLD_INSERT_LIBRARIES="/usr/local/stderred/build/libstderred.dylib${DYLD_INSERT_LIBRARIES:+:$DYLD_INSERT_LIBRARIES}"
	export STDERRED_BLACKLIST="^(gcc.*|g\+\+.*|clang.*|fzf)$"
fi

# Dark Nano
if [[ -f /usr/local/darknano/libdarknano.dylib ]]; then
	# export DYLD_INSERT_LIBRARIES=
	export DYLD_INSERT_LIBRARIES="/usr/local/darknano/libdarknano.dylib${DYLD_INSERT_LIBRARIES:+:$DYLD_INSERT_LIBRARIES}"
fi

export PATH="$PATH:/usr/local/clang-analyze/bin"

export PATH="$PATH:/Users/saagarjha/.cargo/bin"

export HOMEBREW_NO_AUTO_UPDATE=1

export THEOS=~/Git/theos

function fix_python() {
	local command=$1
	shift
	PATH="/usr/bin:$PATH" $command "$@"
}

function lldb() {
	fix_python "$(which lldb)" "$@"
}

function swift() {
	fix_python "$(which swift)" "$@"
}

source /usr/local/bin/virtualenvwrapper.sh
