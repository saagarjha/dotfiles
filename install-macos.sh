#!/bin/sh

. ./shared.sh

install_macports() {
	set -x
	cd macports-base
	./configure && make && sudo make install
	cd ..
	{ set +x; } 2>/dev/null
}


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
{ set +x; } 2>/dev/null
for app in ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari ~/Library/Containers/com.apple.SafariTechnologyPreview/Data/Library/Preferences/com.apple.SafariTechnologyPreview; do
	set -x
	defaults write $app WebKitDeveloperExtrasEnabledPreferenceKey -bool YES # Show the Develop menu
	defaults write $app IncludeDevelopMenu -bool YES # Show the Develop menu
	defaults write $app ShowOverlayStatusBar -bool YES # Show the status bar
	defaults write $app ShowFullURLInSmartSearchField -bool YES # Show the full URL in the address bar
	defaults write $app HistoryAgeInDaysLimit -int 365000 # Keep history "forever"
	defaults write $app AutoOpenSafeDownloads -bool NO # Don't open downloads automatically
	defaults write $app SearchProviderIdentifier -string "com.duckduckgo"
	defaults write $app ShowIconsInTabs -bool YES
	{ set +x; } 2>/dev/null
done
set -x
killall Safari 2> /dev/null
killall Safari\ Technology\ Preview 2> /dev/null

# Mail
defaults write ~/Library/Containers/com.apple.Mail/Data/Library/Preferences/com.apple.mail NumberOfSnippetLines 5
killall Mail 2> /dev/null

# Activity Monitor
defaults write com.apple.ActivityMonitor UpdatePeriod -int 1 # Update frequently
defaults write com.apple.ActivityMonitor IconType -int 5 # Set the dock icon to CPU usage
defaults write com.apple.ActivityMonitor DisplayType -int 4 # Samples show percentage of thread
defaults write com.apple.ActivityMonitor ShowCategory -int 100 # Show All Process
killall Activity\ Monitor 2> /dev/null

defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss"
# Remove clock menu extra
# Remove battery menu extra
defaults write com.apple.menuextra.battery ShowPercent -bool YES # Show percentage in battery menu extra
killall SystemUIServer 2> /dev/null

# Xcode
defaults write com.apple.dt.Xcode DVTTextIndentUsingTabs -bool YES # Use tabs for indentation
defaults write com.apple.dt.Xcode DVTTextShowFoldingSidebar -bool YES # Show the sidebar for indentation depth

# Global
defaults write -g AppleICUForce24HourTime -bool YES # Use 24-hour time
defaults write -g NSQuitAlwaysKeepsWindows -bool YES # Keep windows on quit
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # Full keyboard access in controls
# AppKit
defaults write -g _NS_4445425547 -bool YES # Show an internal AppKit debug menu


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
defaults write com.DanPristupov.Fork diffFontName -int SFMono-Regular # Font to use
killall Fork 2> /dev/null

{ set +x; } 2>/dev/null

export PATH="/opt/local/bin/:$PATH"
ask "Install MacPorts?" && install_macports
if [ -x "$(which port 2> /dev/null)" ]; then
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
ask "Install iterm-theme.py?" && mkdir -p "~/Library/Application Support/iTerm2/Scripts/AutoLaunch/" && checked_copy iterm-theme.py "~/Library/Application Support/iTerm2/Scripts/AutoLaunch/iterm-theme.py"

true
