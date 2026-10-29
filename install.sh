#!/usr/bin/env bash
# Install or update TileIt: the KWin script, the panel widget and the settings app.
set -euo pipefail
cd "$(dirname "$0")"

install_package() {
    local type=$1 dir=$2
    kpackagetool6 --type="$type" -u "$dir" >/dev/null 2>&1 || kpackagetool6 --type="$type" -i "$dir"
}

echo "Installing KWin script…"
install_package KWin/Script kwin
kwriteconfig6 --file kwinrc --group Plugins --key tileitEnabled true
# Reload the script so code changes take effect without logging out.
qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript tileit >/dev/null 2>&1 \
    || qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript tileit >/dev/null 2>&1 || true
qdbus-qt6 org.kde.KWin /KWin reconfigure 2>/dev/null || qdbus6 org.kde.KWin /KWin reconfigure

echo "Installing panel widget…"
install_package Plasma/Applet plasmoid

echo "Installing settings app…"
install -Dm755 settings/tileit-settings "$HOME/.local/bin/tileit-settings"
install -Dm644 settings/tileit-settings.desktop "$HOME/.local/share/applications/tileit-settings.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo
echo "Done. Add the widget via right-click on the panel → Add or Manage Widgets → TileIt,"
echo "and open \"TileIt Settings\" from the app launcher to change shortcuts."
