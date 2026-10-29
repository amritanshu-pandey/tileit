# TileIt

Magnet-style window snapping for KDE Plasma 6 (Wayland and X11).

- `kwin/` — KWin script that moves and resizes windows and registers the keyboard shortcuts.
- `plasmoid/` — panel widget with a clickable grid of layouts. Its settings page lists every
  action with a shortcut recorder (like Magnet's preferences) and the gap between windows.

No dependencies beyond Plasma 6.

## Install

From a checkout:

```sh
./install.sh
```

This installs (or updates and reloads) the KWin script and the widget. Then add the widget via
right-click on the panel → *Add or Manage Widgets* → *TileIt*, and use its **Shortcuts…** button
to change shortcuts.

From release archives (`./package.sh` builds them into `dist/`):

```sh
kpackagetool6 --type=KWin/Script -i tileit-<version>.kwinscript
kpackagetool6 --type=Plasma/Applet -i tileit-<version>.plasmoid
```

then enable TileIt in System Settings → Window Management → KWin Scripts. The same archives can be
uploaded to [store.kde.org](https://store.kde.org) so they show up under *Get New…*.

Remove everything with `./uninstall.sh`.

## Default shortcuts

| Action | Keys |
| --- | --- |
| Left / Right / Top / Bottom half | Ctrl+Alt+← / → / ↑ / ↓ |
| Quarters (TL, TR, BL, BR) | Ctrl+Alt+U / I / J / K |
| Left / Center / Right third | Ctrl+Alt+D / F / G |
| Left / Right two thirds | Ctrl+Alt+E / T |
| Maximize | Ctrl+Alt+Enter |
| Center | Ctrl+Alt+C |
| Restore | Ctrl+Alt+Backspace |
| Next / Previous display | Ctrl+Alt+Meta+→ / ← |
| Sixths | unbound by default |

Shortcuts are stored in KDE's global shortcut service, so they can also be edited in
System Settings → Keyboard → Shortcuts → KWin (search "TileIt").

## Notes

- Layouts are defined in `kwin/contents/code/main.js` (geometry) and
  `plasmoid/contents/ui/layouts.js` (widget and settings page); keep them in sync when adding one.
- The widget triggers the KWin script's shortcuts over D-Bus, so it works for actions that have
  no key assigned.
- Known issue: GTK4 apps (e.g. Ghostty) snapped on a different monitor than the mouse cursor can
  stop short of the screen edge. KWin sends them a size limit based on the cursor's monitor, and
  GTK enforces it.
