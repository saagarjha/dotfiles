#!/bin/sh

. ./shared.sh

if [ ! "$IS_ROOT" ]; then
	SUDO=sudo
else
	SUDO=
fi

ask "Install build-essential?" && $SUDO apt install build-essential
ask "Install cmake?" && $SUDO apt install cmake
ask "Install tig?" && $SUDO apt install tig
ask "Install bashlogin?" && checked_copy bashlogin /bin/bashlogin

set -x

gsettings set org.pantheon.desktop.gala.appearance button-layout close,minimize,maximize

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true

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
