// TileIt — Magnet-style keyboard window snapping for KWin (Plasma 6).

// Layouts are fractions of the screen's usable area (panels excluded).
const LAYOUTS = {
    "Left Half":            { x: 0,     y: 0,   w: 1 / 2, h: 1 },
    "Right Half":           { x: 1 / 2, y: 0,   w: 1 / 2, h: 1 },
    "Top Half":             { x: 0,     y: 0,   w: 1,     h: 1 / 2 },
    "Bottom Half":          { x: 0,     y: 1 / 2, w: 1,   h: 1 / 2 },

    "Top Left Quarter":     { x: 0,     y: 0,     w: 1 / 2, h: 1 / 2 },
    "Top Right Quarter":    { x: 1 / 2, y: 0,     w: 1 / 2, h: 1 / 2 },
    "Bottom Left Quarter":  { x: 0,     y: 1 / 2, w: 1 / 2, h: 1 / 2 },
    "Bottom Right Quarter": { x: 1 / 2, y: 1 / 2, w: 1 / 2, h: 1 / 2 },

    "Left Third":           { x: 0,     y: 0, w: 1 / 3, h: 1 },
    "Center Third":         { x: 1 / 3, y: 0, w: 1 / 3, h: 1 },
    "Right Third":          { x: 2 / 3, y: 0, w: 1 / 3, h: 1 },
    "Left Two Thirds":      { x: 0,     y: 0, w: 2 / 3, h: 1 },
    "Right Two Thirds":     { x: 1 / 3, y: 0, w: 2 / 3, h: 1 },

    "Top Left Sixth":       { x: 0,     y: 0,     w: 1 / 3, h: 1 / 2 },
    "Top Center Sixth":     { x: 1 / 3, y: 0,     w: 1 / 3, h: 1 / 2 },
    "Top Right Sixth":      { x: 2 / 3, y: 0,     w: 1 / 3, h: 1 / 2 },
    "Bottom Left Sixth":    { x: 0,     y: 1 / 2, w: 1 / 3, h: 1 / 2 },
    "Bottom Center Sixth":  { x: 1 / 3, y: 1 / 2, w: 1 / 3, h: 1 / 2 },
    "Bottom Right Sixth":   { x: 2 / 3, y: 1 / 2, w: 1 / 3, h: 1 / 2 },

    "Maximize":             { x: 0, y: 0, w: 1, h: 1 },
};

// Default keys mirror Magnet's Ctrl+Option layout, using Ctrl+Alt.
const DEFAULT_KEYS = {
    "Left Half": "Ctrl+Alt+Left",
    "Right Half": "Ctrl+Alt+Right",
    "Top Half": "Ctrl+Alt+Up",
    "Bottom Half": "Ctrl+Alt+Down",
    "Top Left Quarter": "Ctrl+Alt+U",
    "Top Right Quarter": "Ctrl+Alt+I",
    "Bottom Left Quarter": "Ctrl+Alt+J",
    "Bottom Right Quarter": "Ctrl+Alt+K",
    "Left Third": "Ctrl+Alt+D",
    "Center Third": "Ctrl+Alt+F",
    "Right Third": "Ctrl+Alt+G",
    "Left Two Thirds": "Ctrl+Alt+E",
    "Right Two Thirds": "Ctrl+Alt+T",
    "Maximize": "Ctrl+Alt+Return",
};

const EPSILON = 0.0001;

// Pre-snap geometry per window, used by "Restore".
// { original: rect, applied: rect } keyed by window.internalId.
const saved = {};

function gap() {
    return readConfig("gap", 0);
}

function copyRect(r) {
    return { x: r.x, y: r.y, width: r.width, height: r.height };
}

function sameRect(a, b) {
    return Math.abs(a.x - b.x) < 1 && Math.abs(a.y - b.y) < 1 &&
        Math.abs(a.width - b.width) < 1 && Math.abs(a.height - b.height) < 1;
}

// Last normal window that had focus. Clicking the TileIt widget focuses the
// panel popup, so actions fall back to the window that was active before it.
let lastWindow = null;

function usable(w) {
    return w && w.normalWindow && w.moveable && w.resizeable && !w.fullScreen;
}

function target() {
    const w = workspace.activeWindow;
    if (usable(w)) {
        return w;
    }
    return usable(lastWindow) ? lastWindow : null;
}

function areaFor(w, output) {
    if (output) {
        return workspace.clientArea(KWin.MaximizeArea, output, workspace.currentDesktop);
    }
    return workspace.clientArea(KWin.MaximizeArea, w);
}

// Convert a fractional layout into pixels. Edges are rounded independently
// so adjacent tiles share an edge exactly (e.g. three thirds fill the screen).
function layoutRect(area, l) {
    const g = gap();
    const half = g / 2;
    const left = area.x + Math.round(l.x * area.width);
    const right = area.x + Math.round((l.x + l.w) * area.width);
    const top = area.y + Math.round(l.y * area.height);
    const bottom = area.y + Math.round((l.y + l.h) * area.height);

    const insetLeft = l.x < EPSILON ? g : half;
    const insetRight = l.x + l.w > 1 - EPSILON ? g : half;
    const insetTop = l.y < EPSILON ? g : half;
    const insetBottom = l.y + l.h > 1 - EPSILON ? g : half;

    return {
        x: Math.round(left + insetLeft),
        y: Math.round(top + insetTop),
        width: Math.round(right - left - insetLeft - insetRight),
        height: Math.round(bottom - top - insetTop - insetBottom),
    };
}

// Drop KWin's own maximize / quick-tile state so our geometry sticks.
function release(w) {
    if (w.tile) {
        w.tile = null;
    }
    w.setMaximize(false, false);
}

function remember(w) {
    const current = copyRect(w.frameGeometry);
    const entry = saved[w.internalId];
    // Keep the original geometry while the window is still where we put it;
    // if the user moved it by hand since, that becomes the new original.
    if (!entry || !sameRect(entry.applied, current)) {
        saved[w.internalId] = { original: current, applied: current };
    }
}

function apply(w, rect) {
    release(w);
    w.frameGeometry = rect;
    if (saved[w.internalId]) {
        saved[w.internalId].applied = copyRect(w.frameGeometry);
    }
}

function snap(name) {
    const w = target();
    if (!w) {
        return;
    }
    remember(w);
    apply(w, layoutRect(areaFor(w), LAYOUTS[name]));
}

function center() {
    const w = target();
    if (!w) {
        return;
    }
    const area = areaFor(w);
    const geo = w.frameGeometry;
    const width = Math.min(geo.width, area.width);
    const height = Math.min(geo.height, area.height);
    remember(w);
    apply(w, {
        x: Math.round(area.x + (area.width - width) / 2),
        y: Math.round(area.y + (area.height - height) / 2),
        width: width,
        height: height,
    });
}

function restore() {
    const w = target();
    if (!w) {
        return;
    }
    const entry = saved[w.internalId];
    if (!entry) {
        return;
    }
    delete saved[w.internalId];
    release(w);
    w.frameGeometry = entry.original;
}

// Move the window to the neighbouring display (ordered left to right),
// keeping its position and size proportional to the usable area.
function moveToDisplay(step) {
    const w = target();
    if (!w || !w.moveableAcrossScreens) {
        return;
    }
    const screens = workspace.screens.slice().sort(function (a, b) {
        return a.geometry.x - b.geometry.x || a.geometry.y - b.geometry.y;
    });
    if (screens.length < 2) {
        return;
    }
    const index = screens.indexOf(w.output);
    const dest = screens[(index + step + screens.length) % screens.length];

    const from = areaFor(w);
    const to = areaFor(w, dest);
    const geo = w.frameGeometry;
    const width = Math.min(Math.round(geo.width / from.width * to.width), to.width);
    const height = Math.min(Math.round(geo.height / from.height * to.height), to.height);
    const x = to.x + Math.round((geo.x - from.x) / from.width * to.width);
    const y = to.y + Math.round((geo.y - from.y) / from.height * to.height);

    const maximized = sameRect(geo, layoutRect(from, LAYOUTS["Maximize"]));
    remember(w);
    apply(w, {
        x: Math.max(to.x, Math.min(x, to.x + to.width - width)),
        y: Math.max(to.y, Math.min(y, to.y + to.height - height)),
        width: width,
        height: height,
    });
    if (maximized) {
        apply(w, layoutRect(to, LAYOUTS["Maximize"]));
    }
}

Object.keys(LAYOUTS).forEach(function (name) {
    registerShortcut("TileIt: " + name, "TileIt: " + name, DEFAULT_KEYS[name] || "", function () {
        snap(name);
    });
});

registerShortcut("TileIt: Center", "TileIt: Center", "Ctrl+Alt+C", center);
registerShortcut("TileIt: Restore", "TileIt: Restore", "Ctrl+Alt+Backspace", restore);
registerShortcut("TileIt: Next Display", "TileIt: Next Display", "Ctrl+Alt+Meta+Right", function () {
    moveToDisplay(1);
});
registerShortcut("TileIt: Previous Display", "TileIt: Previous Display", "Ctrl+Alt+Meta+Left", function () {
    moveToDisplay(-1);
});

workspace.windowActivated.connect(function (w) {
    if (usable(w)) {
        lastWindow = w;
    }
});

workspace.windowRemoved.connect(function (w) {
    delete saved[w.internalId];
    if (w === lastWindow) {
        lastWindow = null;
    }
});
