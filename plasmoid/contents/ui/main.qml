import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.dbus as DBus
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Fractions of the screen; names match the TileIt KWin script's shortcuts.
    readonly property var sections: [
        { title: i18n("Halves"), tiles: [
            { name: "Left Half", x: 0, y: 0, w: 1/2, h: 1 },
            { name: "Right Half", x: 1/2, y: 0, w: 1/2, h: 1 },
            { name: "Top Half", x: 0, y: 0, w: 1, h: 1/2 },
            { name: "Bottom Half", x: 0, y: 1/2, w: 1, h: 1/2 } ] },
        { title: i18n("Quarters"), tiles: [
            { name: "Top Left Quarter", x: 0, y: 0, w: 1/2, h: 1/2 },
            { name: "Top Right Quarter", x: 1/2, y: 0, w: 1/2, h: 1/2 },
            { name: "Bottom Left Quarter", x: 0, y: 1/2, w: 1/2, h: 1/2 },
            { name: "Bottom Right Quarter", x: 1/2, y: 1/2, w: 1/2, h: 1/2 } ] },
        { title: i18n("Thirds"), tiles: [
            { name: "Left Third", x: 0, y: 0, w: 1/3, h: 1 },
            { name: "Center Third", x: 1/3, y: 0, w: 1/3, h: 1 },
            { name: "Right Third", x: 2/3, y: 0, w: 1/3, h: 1 },
            { name: "Left Two Thirds", x: 0, y: 0, w: 2/3, h: 1 },
            { name: "Right Two Thirds", x: 1/3, y: 0, w: 2/3, h: 1 } ] },
        { title: i18n("Sixths"), tiles: [
            { name: "Top Left Sixth", x: 0, y: 0, w: 1/3, h: 1/2 },
            { name: "Top Center Sixth", x: 1/3, y: 0, w: 1/3, h: 1/2 },
            { name: "Top Right Sixth", x: 2/3, y: 0, w: 1/3, h: 1/2 },
            { name: "Bottom Left Sixth", x: 0, y: 1/2, w: 1/3, h: 1/2 },
            { name: "Bottom Center Sixth", x: 1/3, y: 1/2, w: 1/3, h: 1/2 },
            { name: "Bottom Right Sixth", x: 2/3, y: 1/2, w: 1/3, h: 1/2 } ] },
        { title: i18n("Other"), tiles: [
            { name: "Maximize", x: 0, y: 0, w: 1, h: 1 },
            { name: "Center", x: 1/4, y: 1/4, w: 1/2, h: 1/2 } ] }
    ]

    Plasmoid.icon: "view-split-left-right"
    toolTipMainText: i18n("TileIt")
    toolTipSubText: i18n("Snap the active window")

    // Close the popup first so focus returns to the window being snapped;
    // the KWin script also falls back to the last focused window.
    function run(action) {
        root.expanded = false;
        invokeTimer.action = action;
        invokeTimer.restart();
    }

    Timer {
        id: invokeTimer
        property string action
        interval: 120
        onTriggered: DBus.SessionBus.asyncCall({
            service: "org.kde.kglobalaccel",
            path: "/component/kwin",
            iface: "org.kde.kglobalaccel.Component",
            member: "invokeShortcut",
            arguments: [new DBus.string("TileIt: " + action)],
            signature: "(s)"
        })
    }

    P5Support.DataSource {
        id: launcher
        engine: "executable"
        onNewData: sourceName => disconnectSource(sourceName)
    }

    fullRepresentation: PlasmaExtras.Representation {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 17
        Layout.preferredHeight: content.implicitHeight + footer.implicitHeight + Kirigami.Units.largeSpacing * 2
        collapseMarginsHint: true

        header: PlasmaExtras.PlasmoidHeading {
            PlasmaExtras.Heading {
                level: 3
                text: i18n("TileIt")
            }
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: root.sections
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: modelData.title
                        opacity: 0.7
                        font: Kirigami.Theme.smallFont
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Repeater {
                            model: modelData.tiles
                            delegate: TileButton {
                                onClicked: root.run(modelData.name)
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing

                PlasmaComponents.ToolButton {
                    icon.name: "edit-undo"
                    text: i18n("Restore")
                    onClicked: root.run("Restore")
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents.ToolButton {
                    icon.name: "go-previous"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("Previous Display")
                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.visible: hovered
                    onClicked: root.run("Previous Display")
                }
                PlasmaComponents.ToolButton {
                    icon.name: "go-next"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("Next Display")
                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.visible: hovered
                    onClicked: root.run("Next Display")
                }
            }
        }

        footer: PlasmaExtras.PlasmoidHeading {
            id: footer
            position: PlasmaComponents.ToolBar.Footer
            contentItem: RowLayout {
                Item { Layout.fillWidth: true }
                PlasmaComponents.ToolButton {
                    icon.name: "configure"
                    text: i18n("Shortcuts…")
                    onClicked: {
                        root.expanded = false;
                        // plasmashell may not have ~/.local/bin on its PATH.
                        launcher.connectSource("tileit-settings 2>/dev/null || \"$HOME/.local/bin/tileit-settings\"");
                    }
                }
            }
        }
    }
}
