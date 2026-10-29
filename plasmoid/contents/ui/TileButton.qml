import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

// A miniature screen with the target area highlighted.
PlasmaComponents.ToolButton {
    id: button

    required property var modelData

    implicitWidth: Kirigami.Units.gridUnit * 3
    implicitHeight: Kirigami.Units.gridUnit * 2
    PlasmaComponents.ToolTip.text: modelData.name
    PlasmaComponents.ToolTip.visible: hovered
    Accessible.name: modelData.name

    contentItem: Item {
        Rectangle {
            id: screen
            anchors.fill: parent
            anchors.margins: 1
            radius: 3
            color: Qt.alpha(Kirigami.Theme.textColor, 0.08)
            border.color: Qt.alpha(Kirigami.Theme.textColor, button.hovered ? 0.8 : 0.45)

            Rectangle {
                readonly property real inset: 2
                readonly property real innerW: screen.width - inset * 2
                readonly property real innerH: screen.height - inset * 2
                x: inset + button.modelData.x * innerW + 0.5
                y: inset + button.modelData.y * innerH + 0.5
                width: button.modelData.w * innerW - 1
                height: button.modelData.h * innerH - 1
                radius: 2
                color: Kirigami.Theme.highlightColor
                opacity: button.hovered ? 1 : 0.8
            }
        }
    }
}
