import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell.Io
import Quickshell

QuickToggleButton {
    id: root
    toggled: false
    visible: false

    property string dnsState: "none"

    buttonIcon: root.dnsState === "warp" ? "cloud_lock" : root.dnsState === "nextdns" ? "shield" : "dns"

    onDnsStateChanged: {
        root.toggled = root.dnsState !== "none";
    }

    onClicked: {
        if (root.dnsState === "none") {
            Quickshell.execDetached(["warp-cli", "connect"]);
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/deactivate.zsh")]);
            root.dnsState = "warp";
        } else if (root.dnsState === "warp") {
            Quickshell.execDetached(["warp-cli", "disconnect"]);
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/activate.zsh")]);
            root.dnsState = "nextdns";
        } else if (root.dnsState === "nextdns") {
            Quickshell.execDetached(["warp-cli", "disconnect"]);
            Quickshell.execDetached(["zsh", "-c", Quickshell.shellPath("scripts/nextdns/deactivate.zsh")]);
            root.dnsState = "none";
        }
    }

    Process {
        id: connectProc
        command: ["warp-cli", "connect"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                Quickshell.execDetached(["notify-send",
                    Translation.tr("Cloudflare WARP"),
                    Translation.tr("Connection failed. Please inspect manually with the <tt>warp-cli</tt> command")
                    , "-a", "Shell"
                ])
            }
        }
    }

    Process {
        id: registrationProc
        command: ["warp-cli", "registration", "new"]
        onExited: (exitCode, exitStatus) => {
            console.log("Warp registration exited with code and status:", exitCode, exitStatus)
            if (exitCode === 0) {
                connectProc.running = true
            } else {
                Quickshell.execDetached(["notify-send",
                    Translation.tr("Cloudflare WARP"),
                    Translation.tr("Registration failed. Please inspect manually with the <tt>warp-cli</tt> command"),
                    "-a", "Shell"
                ])
            }
        }
    }

    Process {
        id: fetchWarpState
        running: true
        command: ["bash", "-c", "warp-cli status"]
        stdout: StdioCollector {
            id: warpStatusCollector
            onStreamFinished: {
                if (warpStatusCollector.text.length > 0) {
                    root.visible = true
                }
                if (warpStatusCollector.text.includes("Unable")) {
                    registrationProc.running = true
                } else if (warpStatusCollector.text.includes("Connected")) {
                    root.dnsState = "warp";
                }
            }
        }
    }

    Process {
        id: fetchNextdnsState
        running: true
        command: ["zsh", "-c", Quickshell.shellPath("scripts/nextdns/status.zsh")]
        stdout: StdioCollector {
            id: nextdnsStatusCollector
            onStreamFinished: {
                if (nextdnsStatusCollector.text.length > 0) {
                    root.visible = true
                }
                if (nextdnsStatusCollector.text.includes("currently activated") && root.dnsState === "none") {
                    root.dnsState = "nextdns";
                }
            }
        }
    }

    StyledToolTip {
        text: root.dnsState === "warp" ? Translation.tr("Cloudflare WARP (1.1.1.1)")
              : root.dnsState === "nextdns" ? Translation.tr("NextDNS")
              : Translation.tr("No DNS service active")
    }
}
