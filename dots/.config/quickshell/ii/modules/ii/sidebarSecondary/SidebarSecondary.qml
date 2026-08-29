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
        visible: GlobalStates.sidebarSecondaryOpen

        function hide() {
            GlobalStates.sidebarSecondaryOpen = false;
        }

        exclusiveZone: 0
        implicitWidth: sidebarWidth
        WlrLayershell.namespace: "quickshell:sidebarSecondary"
        WlrLayershell.keyboardFocus: GlobalStates.sidebarSecondaryOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
            active: GlobalStates.sidebarSecondaryOpen || Config?.options.sidebar.keepSidebarSecondaryLoaded
            anchors {
                fill: parent
                margins: Appearance.sizes.hyprlandGapsOut
                leftMargin: Appearance.sizes.elevationMargin
            }
            width: sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
            height: parent.height - Appearance.sizes.hyprlandGapsOut * 2

            focus: GlobalStates.sidebarSecondaryOpen
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    panelWindow.hide();
                }
            }

            sourceComponent: SidebarSecondaryContent {}
        }
    }

    IpcHandler {
        target: "sidebarSecondary"

        function toggle(): void {
            if (GlobalStates.sidebarSecondaryOpen) close();
            else open();
        }

        function close(): void {
            GlobalStates.sidebarSecondaryOpen = false;
        }

        function open(): void {
            GlobalStates.sidebarSecondaryOpen = true;
            GlobalStates.SidebarRightOpen = false;
        }
    }

    GlobalShortcut {
        name: "sidebarSecondaryToggle"
        description: "Toggles secondary sidebar on press"

        onPressed: {
            if (GlobalStates.sidebarSecondaryOpen) GlobalStates.sidebarSecondaryOpen = false;
            else {
                GlobalStates.sidebarSecondaryOpen = true;
                GlobalStates.sidebarRightOpen = false;
            }
        }
    }
    GlobalShortcut {
        name: "sidebarSecondaryOpen"
        description: "Opens secondary sidebar on press"

        onPressed: {
            GlobalStates.sidebarSecondaryOpen = true;
            GlobalStates.sidebarRightOpen = false;
        }
    }
    GlobalShortcut {
        name: "sidebarSecondaryClose"
        description: "Closes secondary sidebar on press"

        onPressed: {
            GlobalStates.sidebarSecondaryOpen = false;
        }
    }
}
