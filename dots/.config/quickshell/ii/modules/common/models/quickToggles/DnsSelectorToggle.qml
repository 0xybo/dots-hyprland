import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("DNS")

    property string state: "none"
    toggled: root.state !== "none"
    icon: root.state === "warp" ? "cloud_lock" : root.state === "nextdns" ? "shield" : "dns"
    hasStatusText: true
    statusText: root.state === "warp" ? "WARP" : root.state === "nextdns" ? "NextDNS" : Translation.tr("Off")
    tooltipText: root.state === "warp" ? Translation.tr("Cloudflare WARP (1.1.1.1)")
                 : root.state === "nextdns" ? Translation.tr("NextDNS")
                 : Translation.tr("No DNS service active")

    mainAction: () => {
        if (root.state === "none") {
            Quickshell.execDetached(["warp-cli", "connect"]);
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/deactivate.zsh")]);
            root.state = "warp";
        } else if (root.state === "warp") {
            Quickshell.execDetached(["warp-cli", "disconnect"]);
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/activate.zsh")]);
            root.state = "nextdns";
        } else if (root.state === "nextdns") {
            Quickshell.execDetached(["warp-cli", "disconnect"]);
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/deactivate.zsh")]);
            root.state = "none";
        }
    }

    Process {
        id: nextdnsStatusProc
        running: true
        command: ["zsh", "-c", Quickshell.shellPath("scripts/nextdns/status.zsh")]
        stdout: StdioCollector {
            id: nextdnsStatusCollector
            onStreamFinished: {
                if (nextdnsStatusCollector.text.length > 0) {
                    root.available = true;
                }
                if (nextdnsStatusCollector.text.includes("currently activated") && root.state === "none") {
                    root.state = "nextdns";
                }
            }
        }
    }

    Process {
        id: warpStatusProc
        running: true
        command: ["bash", "-c", "warp-cli status"]
        stdout: StdioCollector {
            id: warpStatusCollector
            onStreamFinished: {
                if (warpStatusCollector.text.length > 0) {
                    root.available = true;
                }
                if (warpStatusCollector.text.includes("Connected")) {
                    root.state = "warp";
                } else if (root.state === "warp") {
                    root.state = "none";
                }
            }
        }
    }
}
