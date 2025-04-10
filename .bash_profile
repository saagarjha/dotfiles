# MacPorts, so .bashrc can see commands
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

export PATH="$HOME/bin:$PATH"

. ~/.bashrc

if [[ "$BASH_VERSINFO" -ge 4 ]]; then
	if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
		. /opt/local/etc/profile.d/bash_completion.sh
	elif [ -f /usr/share/bash-completion/bash_completion ]; then
			. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

if [[ "$BASH_VERSINFO" -ge 4 ]]; then
	_completion_loader ssh
	complete -F _ssh cysh
fi

if [[ -f ~/.tokens ]]; then
	. ~/.tokens
fi

if [[ -f ~/.fzy && -t 1 ]]; then
	. ~/.fzy
fi

if [[ -t 1 && -e "${HOME}/.iterm2_shell_integration.bash" ]]; then
	. "${HOME}/.iterm2_shell_integration.bash"
fi

function use_macports() {
	export CFLAGS="-I/opt/local/include"
	export CPPFLAGS="-I/opt/local/include"
	export CXXFLAGS="-I/opt/local/include"
	export LDFLAGS="-L/opt/local/lib"
	export PKG_CONFIG_PATH="/opt/local/lib/pkgconfig"
}

export ASAN_OPTIONS="debug=true:check_initialization_order=true:detect_stack_use_after_return=true:alloc_dealloc_mismatch=true:strict_string_checks=true:detect_invalid_pointer_pairs=1:atexit=true"

export PATH="$PATH:/usr/local/sbin"

# Python
export PATH="$PATH:$(python3 -m site --user-base)/bin"
if [[ -f /usr/local/bin/virtualenvwrapper_lazy.sh ]]; then
	source /usr/local/bin/virtualenvwrapper_lazy.sh
fi

# Ruby
if [[ -x "$(which ruby 2> /dev/null)" ]]; then
	# This is too slow, so do it ourselves
	# export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
	export GEM_HOME="$(ruby --disable=gems -rrbconfig -e 'puts File.join [Dir.home, ".gem", RUBY_ENGINE, RbConfig::CONFIG["ruby_version"]]')"
	export GEM_PATH="$GEM_HOME"
	export PATH="$PATH:$GEM_HOME/bin"
fi

# Rust
export PATH="$PATH:$HOME/.cargo/bin"

# Java
# If the java_home symbolic link is set, then run it to find JAVA_HOME
if [[ -e /usr/libexec/java_home ]]; then
	export JAVA_HOME="$(/usr/libexec/java_home 2> /dev/null)"
fi

# Hadoop
export HADOOP_HOME=/usr/local/hadoop
export PATH="$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"

# Android
export PATH="$PATH:/Users/saagarjha/android-sdks/platform-tools"

# Theos
export THEOS=~/Git/theos

if [[ -x "$(which launchctl 2> /dev/null)" ]]; then
	launchctl setenv PATH $PATH
fi


function insert_libraries() {
	if [[ -f "$1.dylib" ]]; then
		export DYLD_INSERT_LIBRARIES="$1.dylib${DYLD_INSERT_LIBRARIES:+:$DYLD_INSERT_LIBRARIES}"
	elif [[ -f "$1.so" ]]; then
		export LD_PRELOAD="$1.so${LD_PRELOAD:+:$LD_PRELOAD}"
	fi
}

# stderred
insert_libraries ~/.dotfiles/stderred/build/libstderred	
export STDERRED_BLACKLIST="^(gcc.*|g\+\+.*|clang.*)$"

# Nano Fixes
insert_libraries ~/.dotfiles/libfixnano

unset -f insert_libraries

export CUDA_HOME=/usr/local/cuda
export PATH="$PATH:$CUDA_HOME/bin"
