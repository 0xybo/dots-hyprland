import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.sidebarRight.notifications
import qs.modules.ii.sidebarRight.todo
import QtQuick
import Quickshell

Item {
    id: root
    property int sidebarWidth: Appearance.sizes.sidebarWidth
    property int sidebarPadding: 10

    implicitHeight: sidebarBackground.implicitHeight
    implicitWidth: sidebarBackground.implicitWidth

    StyledRectangularShadow {
        target: sidebarBackground
    }
    Rectangle {
        id: sidebarBackground

        anchors.fill: parent
        implicitHeight: parent.height - Appearance.sizes.hyprlandGapsOut * 2
        implicitWidth: sidebarWidth - Appearance.sizes.hyprlandGapsOut * 2
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

        Item {
            id: layoutRoot
            anchors.fill: parent
            anchors.margins: sidebarPadding

            // Notifications section
            Item {
                id: notificationsSection
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(50, parent.height * Persistent.states.sidebar.secondarySplitRatio - splitHandle.height / 2)
                clip: true

                NotificationList {
                    anchors.fill: parent
                }
            }

            // Split handle
            Item {
                id: splitHandle
                anchors.top: notificationsSection.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 8

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    height: 2
                    radius: 1
                    color: Appearance.colors.colLayer0Border
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -4
                    anchors.bottomMargin: -4
                    cursorShape: Qt.SplitVCursor
                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            var newTop = notificationsSection.height + mouse.y;
                            var maxTop = parent.parent.height - 50 - splitHandle.height;
                            var minTop = 50;
                            newTop = Math.max(minTop, Math.min(maxTop, newTop));
                            Persistent.states.sidebar.secondarySplitRatio = newTop / parent.parent.height;
                        }
                    }
                }
            }

            // Todo section
            Item {
                id: todoSection
                anchors.top: splitHandle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                TodoWidget {
                    anchors.fill: parent
                }
            }
        }
    }
}
