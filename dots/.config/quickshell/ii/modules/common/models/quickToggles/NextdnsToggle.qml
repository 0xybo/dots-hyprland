import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("NextDNS")

    toggled: false
    icon: "shield"

    mainAction: () => {
        if (toggled) {
            root.toggled = false;
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/deactivate.zsh")]);
        } else {
            root.toggled = true;
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/activate.zsh")]);
        }
    }

    Process {
        id: connectProc
        command: ["zsh", "-c", Quickshell.shellPath("scripts/nextdns/status.zsh")]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                Quickshell.execDetached(["notify-send", Translation.tr("NextDNS"), Translation.tr("Failed to check NextDNS status. Please inspect manually with the <tt>zsh</tt> command"), "-a", "Shell"]);
            } else {
                fetchActiveState.running = true;
            }
        }
    }

    Process {
        id: fetchActiveState
        running: true
        command: ["zsh", "-c", Quickshell.shellPath("scripts/nextdns/status.zsh")]
        stdout: StdioCollector {
            id: nextdnsStatusCollector
            onStreamFinished: {
                if (nextdnsStatusCollector.text.length > 0) {
                    root.available = true;
                }
                if (nextdnsStatusCollector.text.includes("currently activated")) {
                    root.toggled = true;
                } else if (nextdnsStatusCollector.text.includes("currently deactivated")) {
                    root.toggled = false;
                }
            }
        }
    }

    tooltipText: Translation.tr("NextDNS")
}
