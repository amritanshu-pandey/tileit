#!/usr/bin/env bash
# Remove all TileIt components. Your shortcut choices stay in kglobalshortcutsrc.
set -uo pipefail
kwriteconfig6 --file kwinrc --group Plugins --key tileitEnabled false
qdbus-qt6 org.kde.KWin /KWin reconfigure 2>/dev/null || qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null
kpackagetool6 --type=KWin/Script -r tileit
kpackagetool6 --type=Plasma/Applet -r com.github.amritanshu-pandey.tileit
rm -f "$HOME/.local/bin/tileit-settings" "$HOME/.local/share/applications/tileit-settings.desktop"
