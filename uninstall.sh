#!/usr/bin/env bash
# Remove TileIt. Your shortcut choices stay in kglobalshortcutsrc.
set -uo pipefail
qdbus() { qdbus-qt6 "$@" 2>/dev/null || qdbus6 "$@"; }
kwriteconfig6 --file kwinrc --group Plugins --key tileitEnabled false
qdbus org.kde.KWin /KWin reconfigure
kpackagetool6 --type=KWin/Script -r tileit
kpackagetool6 --type=Plasma/Applet -r com.github.amritanshu-pandey.tileit
