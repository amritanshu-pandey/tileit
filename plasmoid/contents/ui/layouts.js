.pragma library

// Every TileIt action, grouped as in Magnet. Layouts are fractions of the
// screen's usable area; actions without one have an icon instead. Names match
// the KWin script's shortcuts ("TileIt: <name>") — keep in sync with LAYOUTS
// in kwin/contents/code/main.js.
var sections = [
    { title: "Halves", actions: [
        { name: "Left Half", x: 0, y: 0, w: 1/2, h: 1 },
        { name: "Right Half", x: 1/2, y: 0, w: 1/2, h: 1 },
        { name: "Top Half", x: 0, y: 0, w: 1, h: 1/2 },
        { name: "Bottom Half", x: 0, y: 1/2, w: 1, h: 1/2 } ] },
    { title: "Quarters", actions: [
        { name: "Top Left Quarter", x: 0, y: 0, w: 1/2, h: 1/2 },
        { name: "Top Right Quarter", x: 1/2, y: 0, w: 1/2, h: 1/2 },
        { name: "Bottom Left Quarter", x: 0, y: 1/2, w: 1/2, h: 1/2 },
        { name: "Bottom Right Quarter", x: 1/2, y: 1/2, w: 1/2, h: 1/2 } ] },
    { title: "Thirds", actions: [
        { name: "Left Third", x: 0, y: 0, w: 1/3, h: 1 },
        { name: "Center Third", x: 1/3, y: 0, w: 1/3, h: 1 },
        { name: "Right Third", x: 2/3, y: 0, w: 1/3, h: 1 },
        { name: "Left Two Thirds", x: 0, y: 0, w: 2/3, h: 1 },
        { name: "Right Two Thirds", x: 1/3, y: 0, w: 2/3, h: 1 } ] },
    { title: "Sixths", actions: [
        { name: "Top Left Sixth", x: 0, y: 0, w: 1/3, h: 1/2 },
        { name: "Top Center Sixth", x: 1/3, y: 0, w: 1/3, h: 1/2 },
        { name: "Top Right Sixth", x: 2/3, y: 0, w: 1/3, h: 1/2 },
        { name: "Bottom Left Sixth", x: 0, y: 1/2, w: 1/3, h: 1/2 },
        { name: "Bottom Center Sixth", x: 1/3, y: 1/2, w: 1/3, h: 1/2 },
        { name: "Bottom Right Sixth", x: 2/3, y: 1/2, w: 1/3, h: 1/2 } ] },
    { title: "Other", actions: [
        { name: "Maximize", x: 0, y: 0, w: 1, h: 1 },
        { name: "Center", x: 1/4, y: 1/4, w: 1/2, h: 1/2 },
        { name: "Restore", icon: "edit-undo" },
        { name: "Previous Display", icon: "go-previous" },
        { name: "Next Display", icon: "go-next" } ] }
];

function isLayout(action) {
    return action.icon === undefined;
}
