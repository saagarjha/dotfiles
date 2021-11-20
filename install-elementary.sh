#!/bin/sh

. ./shared.sh

if [ ! "$IS_ROOT" ]; then
	sudo=sudo
else
	sudo=
fi

install_wingpanel_indicator_sys_monitor() {
	set -x
	(
		cd wingpanel-indicator-sys-monitor
		$sudo apt install libgtop2-dev libgranite-dev libgtk-3-dev libwingpanel-2.0-dev meson valac
		meson build --prefix=/usr
		cd build
		ninja
		$sudo ninja install
	)
	{ set +x; } 2>/dev/null
}

ask "Install build-essential?" && $sudo apt install build-essential
ask "Install cmake?" && $sudo apt install cmake
ask "Install clang-format?" && $sudo apt install clang-format
ask "Install tig?" && $sudo apt install tig
ask "Install ag?" && $sudo apt install silversearcher-ag
ask "Install bashlogin?" && checked_copy bashlogin /bin/bashlogin

ask "Install wingpanel-indicator-sys-monitor?" && install_wingpanel_indicator_sys_monitor

set -x

gsettings set org.pantheon.desktop.gala.appearance button-layout close,minimize,maximize

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true

gsettings set io.elementary.desktop.wingpanel.datetime clock-format 24h
gsettings set io.elementary.desktop.wingpanel.datetime clock-show-seconds true
gsettings set io.elementary.desktop.wingpanel.datetime show-weeks true

gsettings set io.elementary.desktop.wingpanel.power show-percentage true

gsettings set io.elementary.terminal.settings natural-copy-paste false
gsettings set io.elementary.terminal.settings shell bashlogin

gsettings set org.gnome.Epiphany.web:/org/gnome/epiphany/web/ enable-adblock true

cat > ~/.config/plank/dock1/launchers/io.elementary.files.dockitem <<EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/io.elementary.files.desktop
EOF
cat > ~/.config/plank/dock1/launchers/org.gnome.Epiphany.dockitem << EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/org.gnome.Epiphany.desktop
EOF
cat > ~/.config/plank/dock1/launchers/io.elementary.appcenter.dockitem <<EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/io.elementary.appcenter.desktop
EOF
cat > ~/.config/plank/dock1/launchers/io.elementary.calculator.dockitem <<EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/io.elementary.calculator.desktop
EOF
cat > ~/.config/plank/dock1/launchers/gparted.dockitem <<EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/gparted.desktop
EOF
cat > ~/.config/plank/dock1/launchers/io.elementary.terminal.dockitem << EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/io.elementary.terminal.desktop
EOF
cat > ~/.config/plank/dock1/launchers/io.elementary.switchboard.dockitem <<EOF
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/io.elementary.switchboard.desktop
EOF

{ set +x; } 2>/dev/null

true
