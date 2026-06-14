import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    property int sidebarWidth: Appearance.sizes.sidebarWidth

    PanelWindow {
        id: panelWindow
        visible: GlobalStates.sidebarRightMiniOpen

        function hide() {
            GlobalStates.sidebarRightMiniOpen = false;
        }

        exclusiveZone: 0
        implicitWidth: sidebarWidth
        WlrLayershell.namespace: "quickshell:sidebarRightMini"
        WlrLayershell.keyboardFocus: GlobalStates.sidebarRightMiniOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        onVisibleChanged: {
            if (visible) {
                GlobalFocusGrab.addDismissable(panelWindow);
            } else {
                GlobalFocusGrab.removeDismissable(panelWindow);
            }
        }
        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                panelWindow.hide();
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalStates.sidebarRightMiniOpen || Config?.options.sidebar.keepSidebarRightMiniLoaded
            anchors {
                fill: parent
                margins: Appearance.sizes.hyprlandGapsOut
                leftMargin: Appearance.sizes.elevationMargin
            }
            width: sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
            height: parent.height - Appearance.sizes.hyprlandGapsOut * 2

            focus: GlobalStates.sidebarRightMiniOpen
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    panelWindow.hide();
                }
            }

            sourceComponent: SidebarRightMiniContent {}
        }
    }

    IpcHandler {
        target: "sidebarRightMini"

        function toggle(): void {
            GlobalStates.sidebarRightMiniOpen = !GlobalStates.sidebarRightMiniOpen;
        }

        function close(): void {
            GlobalStates.sidebarRightMiniOpen = false;
        }

        function open(): void {
            GlobalStates.sidebarRightMiniOpen = true;
        }
    }

    GlobalShortcut {
        name: "sidebarRightMiniToggle"
        description: "Toggles mini right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightMiniOpen = !GlobalStates.sidebarRightMiniOpen;
        }
    }
    GlobalShortcut {
        name: "sidebarRightMiniOpen"
        description: "Opens mini right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightMiniOpen = true;
        }
    }
    GlobalShortcut {
        name: "sidebarRightMiniClose"
        description: "Closes mini right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightMiniOpen = false;
        }
    }
}
