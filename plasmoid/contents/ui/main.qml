import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.dbus as DBus
import org.kde.kirigami as Kirigami

import "layouts.js" as Layouts

PlasmoidItem {
    id: root

    property bool scriptLoaded: true

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

    function checkScript() {
        DBus.SessionBus.asyncCall({
            service: "org.kde.KWin",
            path: "/Scripting",
            iface: "org.kde.kwin.Scripting",
            member: "isScriptLoaded",
            arguments: ["tileit"],
            signature: "(s)"
        }, reply => root.scriptLoaded = reply.value?.value ?? reply.value);
    }

    onExpandedChanged: {
        if (expanded) {
            checkScript();
        }
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
            arguments: ["TileIt: " + action],
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
        Layout.preferredHeight: (root.scriptLoaded ? content.implicitHeight : Kirigami.Units.gridUnit * 12)
            + footer.implicitHeight + Kirigami.Units.largeSpacing * 2
        collapseMarginsHint: true

        header: PlasmaExtras.PlasmoidHeading {
            PlasmaExtras.Heading {
                level: 3
                text: i18n("TileIt")
            }
        }

        PlasmaExtras.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit * 2
            visible: !root.scriptLoaded
            iconName: "dialog-warning"
            text: i18n("TileIt KWin script isn't running")
            explanation: i18n("Install and enable it under Window Management → KWin Scripts.")
            helpfulAction: Kirigami.Action {
                icon.name: "configure"
                text: i18n("Open KWin Scripts")
                onTriggered: {
                    root.expanded = false;
                    launcher.connectSource("kcmshell6 kcm_kwin_scripts");
                }
            }
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing
            visible: root.scriptLoaded

            Repeater {
                model: Layouts.sections
                delegate: ColumnLayout {
                    id: section
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: i18n(section.modelData.title)
                        opacity: 0.7
                        font: Kirigami.Theme.smallFont
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Repeater {
                            model: section.modelData.actions.filter(Layouts.isLayout)
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
                        Plasmoid.internalAction("configure").trigger();
                    }
                }
            }
        }
    }
}
