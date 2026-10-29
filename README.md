# TileIt

Magnet-style window snapping for KDE Plasma 6 (Wayland and X11).

- `kwin/` — KWin script that moves and resizes windows; registers all the shortcuts.
- `settings/` — **TileIt Settings**, a Magnet-like preferences window for picking shortcuts and the window gap.
- `plasmoid/` — panel widget with a clickable grid of layouts.

## Install / update

```sh
./install.sh
```

This installs (or updates and reloads) all three. Then:

- open **TileIt Settings** from the app launcher to change shortcuts, and
- add the widget via right-click on the panel → *Add or Manage Widgets* → *TileIt*.

The settings app needs PyQt6 and dbus-python (`python3-pyqt6`, `python3-dbus` on Fedora).

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

- Layout fractions are listed in three places (`kwin/contents/code/main.js`,
  `settings/tileit-settings`, `plasmoid/contents/ui/main.qml`); keep them in sync
  when adding a layout.
- The widget triggers the KWin script's shortcuts over D-Bus, so it works even for
  actions that have no key assigned.
