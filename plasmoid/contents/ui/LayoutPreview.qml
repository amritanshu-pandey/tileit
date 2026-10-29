import QtQuick
import org.kde.kirigami as Kirigami

// A miniature screen with the action's target area highlighted, or its icon
// for actions that aren't a layout.
Rectangle {
    id: screen

    required property var action
    property bool highlighted: false

    implicitWidth: Kirigami.Units.gridUnit * 2.5
    implicitHeight: Kirigami.Units.gridUnit * 1.6
    radius: 3
    color: Qt.alpha(Kirigami.Theme.textColor, 0.08)
    border.color: Qt.alpha(Kirigami.Theme.textColor, highlighted ? 0.8 : 0.45)

    Rectangle {
        readonly property real inset: 2
        readonly property real innerW: screen.width - inset * 2
        readonly property real innerH: screen.height - inset * 2
        visible: screen.action.icon === undefined
        x: inset + (screen.action.x ?? 0) * innerW + 0.5
        y: inset + (screen.action.y ?? 0) * innerH + 0.5
        width: (screen.action.w ?? 0) * innerW - 1
        height: (screen.action.h ?? 0) * innerH - 1
        radius: 2
        color: Kirigami.Theme.highlightColor
        opacity: screen.highlighted ? 1 : 0.8
    }

    Kirigami.Icon {
        visible: screen.action.icon !== undefined
        source: screen.action.icon ?? ""
        anchors.centerIn: parent
        width: Kirigami.Units.iconSizes.small
        height: width
    }
}
