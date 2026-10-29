#!/usr/bin/env bash
# Build installable archives in dist/: tileit-<version>.kwinscript and
# tileit-<version>.plasmoid. Install with "kpackagetool6 -i <file>" or upload
# them to store.kde.org.
set -euo pipefail
cd "$(dirname "$0")"

version() { python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Version"])' "$1"; }

rm -rf dist && mkdir dist
(cd kwin && zip -qr "../dist/tileit-$(version metadata.json).kwinscript" .)
(cd plasmoid && zip -qr "../dist/tileit-$(version metadata.json).plasmoid" .)
ls -1 dist
