#!/usr/bin/env bash
# Install or update TileIt from this checkout: the KWin script and the panel widget.
set -euo pipefail
cd "$(dirname "$0")"

qdbus() { qdbus-qt6 "$@" 2>/dev/null || qdbus6 "$@"; }

install_package() {
    local type=$1 dir=$2
    kpackagetool6 --type="$type" -u "$dir" >/dev/null 2>&1 || kpackagetool6 --type="$type" -i "$dir"
}

echo "Installing KWin script…"
install_package KWin/Script kwin
kwriteconfig6 --file kwinrc --group Plugins --key tileitEnabled true
# Reload the script so code changes take effect without logging out.
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript tileit >/dev/null || true
qdbus org.kde.KWin /KWin reconfigure

echo "Installing panel widget…"
install_package Plasma/Applet plasmoid

# Clean up the old Python settings app from earlier versions.
rm -f "$HOME/.local/bin/tileit-settings" "$HOME/.local/share/applications/tileit-settings.desktop"

echo
echo "Done. Add the widget via right-click on the panel → Add or Manage Widgets → TileIt."
echo "Change shortcuts from the widget's Shortcuts… button."
