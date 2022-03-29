#!/bin/sh

. ./shared.sh

install_macports() {
	set -x
	git submodule update --init macports-base
	(
		cd macports-base
		git remote add macports https://github.com/macports/macports-base.git || true
		git fetch macports
		git checkout selfupdate
		git branch --set-upstream-to=macports/master
		git pull macports master --rebase --autostash
		./configure && make -j "$(sysctl -n hw.ncpu)" && sudo make install
	)
	{ set +x; } 2>/dev/null
}

set_defaults() {
	set -x
	
	# Dock
	defaults write com.apple.dock showAppExposeGestureEnabled -bool YES # Enable the Expose gesture
	defaults write com.apple.dock mru-spaces -bool NO # Disable reordering Spaces based on use
	defaults write com.apple.dock expose-group-apps -bool YES # Group apps in Expose
	defaults write com.apple.dock slow-motion-allowed -bool YES # Enable slow motion when pressing modifier keys
	defaults write com.apple.dock mineffect -string suck # Use the suck animation for minimization
	defaults write com.apple.dock show-recents -bool NO # Disable recent apps
	# Use list for Downloads folder dock tile
	killall Dock 2> /dev/null
	
	# Finder
	defaults write com.apple.finder QLEnableTextSelection -bool YES # Enable text selection from Quick Look
	defaults write com.apple.finder ShowStatusBar -bool YES # Show the status bar
	defaults write com.apple.finder AppleShowAllFiles -bool YES # Show all files
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool YES # Show hard drives on the desktop
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool YES # Show external hard drives on the desktop
	defaults write com.apple.finder QuitMenuItem -bool YES # Show the Quit menu item
	defaults write com.apple.finder ShowPathbar -bool YES # Show the path bar
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool NO # Disable the extension change warning
	killall Finder 2> /dev/null
	
	# Safari
	killall Safari 2> /dev/null
	killall "Safari Technology Preview" 2> /dev/null
	{ set +x; } 2>/dev/null
	for app in ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari ~/Library/Containers/com.apple.SafariTechnologyPreview/Data/Library/Preferences/com.apple.SafariTechnologyPreview; do
		set -x
		defaults write $app IncludeDevelopMenu -bool YES # Show the Develop menu
		defaults write $app WebKitDeveloperExtrasEnabledPreferenceKey -bool YES # Show the Develop menu
		defaults write $app WebKitPreferences.developerExtrasEnabled -bool YES # Show the Develop menu
		defaults write $app IncludeDevelopMenu -bool YES # Show the Develop menu
		defaults write $app ShowOverlayStatusBar -bool YES # Show the status bar
		defaults write $app ShowFullURLInSmartSearchField -bool YES # Show the full URL in the address bar
		defaults write $app HistoryAgeInDaysLimit -int 365000 # Keep history "forever"
		defaults write $app AutoOpenSafeDownloads -bool NO # Don't open downloads automatically
		defaults write $app SearchProviderIdentifier -string "com.duckduckgo"
		defaults write $app ShowIconsInTabs -bool YES
		{ set +x; } 2>/dev/null
	done
	
	for app in com.apple.Safari.SandboxBroker com.apple.SafariTechnologyPreview.SandboxBroker; do
		set -x
		defaults write $app ShowDevelopMenu -bool YES
		{ set +x; } 2>/dev/null
	done
	set -x
	
	# Mail
	killall Mail 2> /dev/null
	defaults write ~/Library/Containers/com.apple.Mail/Data/Library/Preferences/com.apple.mail NumberOfSnippetLines 5
	
	# Activity Monitor
	killall Activity\ Monitor 2> /dev/null
	defaults write com.apple.ActivityMonitor UpdatePeriod -int 1 # Update frequently
	defaults write com.apple.ActivityMonitor IconType -int 5 # Set the dock icon to CPU usage
	defaults write com.apple.ActivityMonitor DisplayType -int 4 # Samples show percentage of thread
	defaults write com.apple.ActivityMonitor ShowCategory -int 100 # Show All Process
	
	# Disk Utility
	killall Disk\ Utility 2> /dev/null
	defaults write com.apple.DiskUtility SidebarShowAllDevices -bool YES # Show all devices in the sidebar
	defaults write com.apple.DiskUtility WorkspaceShowAPFSSnapshots -bool YES # Show APFS shapshots

	# Quartz Debug
	killall "Quartz Debug" 2> /dev/null
	defaults write com.apple.QuartzDebug QuartzDebugPrivateInterface -bool YES # Make Quartz Debug actually work
	defaults write com.apple.QuartzDebug QDDockShowFramemeterHistory -bool YES # Show frame history in dock icon
	defaults write com.apple.QuartzDebug QDDockShowNumericalFps -bool YES # Show FPS in dock icon
	defaults write com.apple.QuartzDebug QDShowWindowInfoOnMouseOver -bool YES # Show a debug menu when you press ⌃⌥ while hovering over a window
	
	defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss"
	# Remove clock menu extra
	# Remove battery menu extra
	defaults write com.apple.menuextra.battery ShowPercent -bool YES # Show percentage in battery menu extra
	killall SystemUIServer 2> /dev/null
	
	# Xcode
	defaults write com.apple.dt.Xcode DVTTextIndentUsingTabs -bool YES # Use tabs for indentation
	defaults write com.apple.dt.Xcode DVTTextShowFoldingSidebar -bool YES # Show the sidebar for indentation depth
	defaults write com.apple.dt.Xcode IDEAlwaysShowCompressedStackFrames -bool NO # Show the full stack trace in the sidebar
	defaults write com.apple.dt.Xcode IDEFileExtensionDisplayMode -int 1 # Show file extensions
	defaults write com.apple.dt.Xcode IDEIssueNavigatorDetailLevel -int 30 # Show up to 30 lines of detail in the issue navigator
	defaults write com.apple.dt.Xcode IDESearchNavigatorDetailLevel -int 30 # Show up to 30 lines of detail when searching
	defaults write com.apple.dt.Xcode ShowDVTDebugMenu -bool YES # Show the build number in the app icon
	
	# Global
	defaults write -g AppleICUForce24HourTime -bool YES # Use 24-hour time
	defaults write -g AppleKeyboardUIMode -int 3 # Full keyboard access in controls
	defaults write -g ApplePressAndHoldEnabled -bool NO # Allow keyboard repeat
	defaults write -g InitialKeyRepeat -int 15 # Faster initial key repeat (225 ms)
	defaults write -g NSQuitAlwaysKeepsWindows -bool YES # Keep windows on quit
	defaults write -g KeyRepeat -int 2 # Faster key repeat (30 ms)
	defaults write -g NSAutomaticSpellingCorrectionEnabled -bool NO # Disable automatic spelling correction
	defaults write -g WebAutomaticSpellingCorrectionEnabled -bool NO # Disable automatic spelling correction for websites
	defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool NO # Disable automatic period insertion
	defaults write -g com.apple.sound.beep.feedback -bool YES # Make noise when using the volume keys
	# AppKit
	defaults write -g _NS_4445425547 -bool YES # Show an internal AppKit debug menu
	# Universal Access
	defaults write com.apple.universalaccess showWindowTitlebarIcons -bool YES # Show proxy icon in titlebar
	
	# iTerm2
	defaults write com.googlecode.iterm2 EnableProxyIcon -bool YES # Enable proxy icon in titlebar
	# defaults write com.googlecode.iterm2 AggressiveFocusFollowsMouse -bool YES # Focus follows mouse on activation
	defaults write com.googlecode.iterm2 AutoHideTmuxClientSession -bool YES # Bury tmux sessions when they start
	defaults write com.googlecode.iterm2 DoubleClickPerformsSmartSelection -bool YES # Smart selection on double click
	defaults write com.googlecode.iterm2 BootstrapDaemon -bool NO # Don't boostrap into a daemon; as this breaks Touch ID PAM
	defaults write com.googlecode.iterm2 UseSystemCursorWhenPossible -bool YES # Don't use ugly cursors
	defaults write com.googlecode.iterm2 FocusFollowsMouse -bool YES # Focus follows mouse inside of iTerm
	defaults write com.googlecode.iterm2 StealKeyFocus -bool YES # Focus follows mouse outside of iTerm
	defaults write com.googlecode.iterm2 OpenTmuxWindowsIn -int 2 # Open in tabs in the same window
	defaults write com.googlecode.iterm2 WindowNumber -bool NO # No window number
	defaults write com.googlecode.iterm2 HideTabNumber -bool YES # No tab number
	defaults write com.googlecode.iterm2 AlternateMouseScroll -bool YES # Scroll in man pages, less, etc. with the scroll wheel
	killall iTerm2 2> /dev/null
	
	# Fork
	defaults write com.DanPristupov.Fork useMonospaceInCommitDescription -bool YES # Monospaced font in commit description
	defaults write com.DanPristupov.Fork terminalClient -int 1 # Use iTerm
	defaults write com.DanPristupov.Fork pageGuideLinePosition -int 72 # Commit message body column
	defaults write com.DanPristupov.Fork diffShowHiddenSymbols -bool YES # Show whitespace
	defaults write com.DanPristupov.Fork diffFontName -string SFMono-Regular # Font to use
	killall Fork 2> /dev/null
	
	{ set +x; } 2>/dev/null
}

install_library_injector() {
	set -x
	git submodule update --init library_injector
	git submodule update --init swizzler
	xcrun clang++ -arch arm64e -arch arm64 -arch x86_64 -std=c++20 library_injector/library_injector.cpp -lbsm -lEndpointSecurity -o library_injector/library_injector
	codesign -s - --entitlements library_injector_entitlements.plist library_injector/library_injector
	{ set +x; } 2>/dev/null
	checked_copy library_injector/library_injector ~/bin/library_injector
}

install_launch_daemon() {
	checked_copy "$1" "/Library/LaunchDaemons/$1"
	set -x
	sudo chown root:wheel "/Library/LaunchDaemons/$1"
	{ set +x; } 2>/dev/null
}

install_force_full_desktop_bar() {
	install_library_injector
	set -x
	xcrun clang++ -std=c++20 force_full_desktop_bar.mm -framework Foundation -framework CoreGraphics -shared -arch arm64e -arch arm64 -arch x86_64 -o libforce_full_desktop_bar.dylib
	{ set +x; } 2>/dev/null
	install_launch_daemon com.saagarjha.ForceFullDesktopBar.plist
}

install_ios_scaler() {
	install_library_injector
	set -x
	xcrun clang++ -std=c++20 ios_scaler.mm -framework Foundation -framework CoreGraphics -shared -arch arm64e -arch arm64 -arch x86_64 -o libios_scaler.dylib
	codesign -s "Apple Development" libios_scaler.dylib
	{ set +x; } 2>/dev/null
	install_launch_daemon com.saagarjha.iOSScaler.plist
}

install_disable_diagnostics_reporter() {
	install_library_injector
	set -x
	xcrun clang disable_diagnostics_reporter.c -F /System/Library/PrivateFrameworks -framework CrashReporterSupport -shared -arch arm64e -arch arm64 -arch x86_64 -o libdisable_diagnostics_reporter.dylib
	{ set +x; } 2>/dev/null
	install_launch_daemon com.saagarjha.DisableDiagnosticsReporter.plist
}

export PATH="/opt/local/bin/:$PATH"
ask "Set defaults?" && set_defaults
ask "Install MacPorts?" && install_macports
if [ -x "$(which port 2> /dev/null)" ] && ask "Update ports?"; then
	set -x
	sudo port selfupdate
	{ set +x; } 2>/dev/null
fi
ask "Install bash?" && sudo port install bash bash-completion && {
	grep "/opt/local/bin/bash" /etc/shells || { echo /opt/local/bin/bash | sudo tee -a /etc/shells; }
	chsh -s /opt/local/bin/bash
}
ask "Install git?" && sudo port install git
ask "Install nano?" && sudo port install nano
ask "Install coreutils?" && sudo port install coreutils
ask "Install jq?" && sudo port install jq
ask "Install ag?" && sudo port install the_silver_searcher
ask "Install cmake?" && sudo port install cmake

ask "Install SF Mono?" && cp -R /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/. ~/Library/Fonts/

ask "Copy Karabiner?" && checked_copy karabiner ~/.config/karabiner
ask "Copy Hammerspoon?" && checked_copy .hammerspoon ~/.hammerspoon
ask "Install Xcode keybindings?" && checked_copy Default.idekeybindings ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings
ask "Install Xcode themes?" && checked_copy FontAndColorThemes ~/Library/Developer/Xcode/UserData/FontAndColorThemes && defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme -string 'Solarized (Light).xccolortheme'

ask "Install sysctl modifications?" && checked_copy sysctl.plist /Library/LaunchDaemons
ask "Install hyper key remap?" && checked_copy com.saagarjha.RemapHyper.plist ~/Library/LaunchAgents/com.saagarjha.RemapHyper.plist && launchctl load ~/Library/LaunchAgents/com.saagarjha.RemapHyper.plist
ask "Install force full desktop bar?" && install_force_full_desktop_bar
ask "Install iOS scaler?" && install_ios_scaler
ask "Install disable diagnostics reporter?" && install_disable_diagnostics_reporter

true
