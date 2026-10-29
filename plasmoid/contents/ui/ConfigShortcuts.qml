import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.dbus as DBus

import "layouts.js" as Layouts

// Magnet-style shortcut list. Shortcuts live in KDE's global shortcut daemon
// (kglobalaccel) under the "kwin" component, so changes apply immediately and
// stay in sync with System Settings → Shortcuts.
KCM.SimpleKCM {
    id: page

    property bool scriptLoaded: true
    // Action name → combined key code (0 when unassigned).
    property var keys: ({})
    property var defaults: ({})
    readonly property var allActions: Layouts.sections.reduce((all, section) => all.concat(section.actions), [])

    function actionId(name) {
        return ["kwin", "TileIt: " + name, "KWin", "TileIt: " + name];
    }

    // The D-Bus module wraps basic values as {value: …}.
    function unwrap(v) {
        return v !== null && typeof v === "object" && "value" in v ? v.value : v;
    }

    function call(service, path, iface, member, signature, args, done) {
        DBus.SessionBus.asyncCall({
            service: service, path: path, iface: iface, member: member,
            signature: signature, arguments: args
        }, reply => done && done(reply.value), error => console.warn("TileIt:", member, error.message));
    }

    function accel(member, signature, args, done) {
        call("org.kde.kglobalaccel", "/kglobalaccel", "org.kde.KGlobalAccel", member, signature, args, done);
    }

    // Fetch one int-array result per action, then hand back name → first key.
    function fetchAll(member, done) {
        const result = {};
        let pending = allActions.length;
        allActions.forEach(action => accel(member, "(as)", [actionId(action.name)], value => {
            const list = (value || []).map(unwrap).filter(k => k !== 0);
            result[action.name] = list.length ? list[0] : 0;
            if (--pending === 0) {
                done(result);
            }
        }));
    }

    function reload() {
        call("org.kde.KWin", "/Scripting", "org.kde.kwin.Scripting", "isScriptLoaded", "(s)", ["tileit"],
             loaded => page.scriptLoaded = unwrap(loaded));
        fetchAll("shortcut", result => page.keys = result);
    }

    // sequence is a key sequence from KeySequenceItem or a combined key code.
    function assign(name, sequence) {
        const empty = sequence === 0 || String(sequence) === "";
        accel("setForeignShortcut", "(asai)", [actionId(name), empty ? [] : [sequence]], () => reload());
    }

    function resetAll() {
        allActions.forEach(action => assign(action.name, defaults[action.name] || 0));
    }

    Component.onCompleted: {
        reload();
        fetchAll("defaultShortcut", result => page.defaults = result);
        gapLoader.connectSource("kreadconfig6 --file kwinrc --group Script-tileit --key gap --default 0");
    }

    P5Support.DataSource {
        id: gapLoader
        engine: "executable"
        onNewData: (source, data) => {
            gapSpin.value = parseInt(data.stdout) || 0;
            disconnectSource(source);
        }
    }

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (source, data) => {
            disconnectSource(source);
            if (source.startsWith("kwriteconfig6")) {
                // Let the KWin script pick up the new gap.
                page.call("org.kde.KWin", "/KWin", "org.kde.KWin", "reconfigure", "", []);
            }
        }
    }

    header: Kirigami.InlineMessage {
        visible: !page.scriptLoaded
        type: Kirigami.MessageType.Warning
        position: Kirigami.InlineMessage.Position.Header
        text: i18n("The TileIt KWin script isn't running, so these shortcuts won't do anything. Install and enable it under Window Management → KWin Scripts.")
        actions: Kirigami.Action {
            icon.name: "configure"
            text: i18n("Open KWin Scripts")
            onTriggered: runner.connectSource("kcmshell6 kcm_kwin_scripts")
        }
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Repeater {
            model: Layouts.sections
            delegate: ColumnLayout {
                id: section
                required property var modelData
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    text: i18n(section.modelData.title)
                }

                Repeater {
                    model: section.modelData.actions
                    delegate: RowLayout {
                        id: row
                        required property var modelData
                        readonly property int current: page.keys[modelData.name] || 0
                        readonly property int defaultKey: page.defaults[modelData.name] || 0
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing

                        // keySequence is set imperatively: the recorder writes
                        // to it internally, which would break a binding.
                        onCurrentChanged: recorder.keySequence = current || ""
                        Component.onCompleted: recorder.keySequence = current || ""

                        LayoutPreview {
                            action: row.modelData
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            text: i18n(row.modelData.name)
                            elide: Text.ElideRight
                        }
                        KQuickControls.KeySequenceItem {
                            id: recorder
                            enabled: page.scriptLoaded
                            onKeySequenceModified: page.assign(row.modelData.name, keySequence)
                        }
                        QQC2.ToolButton {
                            icon.name: "edit-reset"
                            enabled: page.scriptLoaded && row.current !== row.defaultKey
                            onClicked: page.assign(row.modelData.name, row.defaultKey)
                            display: QQC2.AbstractButton.IconOnly
                            text: i18n("Reset to default")
                            QQC2.ToolTip.text: text
                            QQC2.ToolTip.visible: hovered
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.SpinBox {
                id: gapSpin
                Kirigami.FormData.label: i18n("Gap between windows:")
                from: 0
                to: 200
                textFromValue: value => i18n("%1 px", value)
                valueFromText: text => parseInt(text) || 0
                onValueModified: gapTimer.restart()

                Timer {
                    id: gapTimer
                    interval: 400
                    onTriggered: runner.connectSource("kwriteconfig6 --file kwinrc --group Script-tileit --key gap " + gapSpin.value)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            QQC2.Label {
                Layout.fillWidth: true
                text: i18n("Changes apply immediately.")
                opacity: 0.7
                wrapMode: Text.WordWrap
            }
            QQC2.Button {
                icon.name: "edit-reset"
                text: i18n("Restore All Defaults")
                enabled: page.scriptLoaded
                onClicked: page.resetAll()
            }
        }
    }
}
