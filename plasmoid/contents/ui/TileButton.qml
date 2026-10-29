import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmaComponents.ToolButton {
    id: button

    required property var modelData

    implicitWidth: Kirigami.Units.gridUnit * 3
    implicitHeight: Kirigami.Units.gridUnit * 2
    PlasmaComponents.ToolTip.text: modelData.name
    PlasmaComponents.ToolTip.visible: hovered
    Accessible.name: modelData.name

    contentItem: Item {
        LayoutPreview {
            anchors.fill: parent
            anchors.margins: 1
            action: button.modelData
            highlighted: button.hovered
        }
    }
}
