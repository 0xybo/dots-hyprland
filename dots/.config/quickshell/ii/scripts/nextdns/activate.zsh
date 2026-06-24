function nextdns_activate() {
    local NM_DIR="/etc/NetworkManager"
    local DNSMASQ_DIR="$NM_DIR/dnsmasq.d"
    local CONFIG_FILE_ACTIVATED="$DNSMASQ_DIR/nextdns.conf"
    local CONFIG_FILE_DEACTIVATED="$DNSMASQ_DIR/.disabled.nextdns.conf"

    if [[ -f "$CONFIG_FILE_DEACTIVATED" ]]; then
        echo "Activating NextDNS configuration..."
        mv "$CONFIG_FILE_DEACTIVATED" "$CONFIG_FILE_ACTIVATED"
        if [[ $? -ne 0 ]]; then
            echo "Failed to reload NetworkManager. Please check your permissions."
            return 1
        fi
        nmcli general reload
        if [[ $? -ne 0 ]]; then
            echo "Failed to reload NetworkManager. Please check your permissions."
            return 1
        fi
        echo "NextDNS configuration activated."
    elif [[ -f "$CONFIG_FILE_ACTIVATED" ]]; then
        echo "NextDNS configuration is already activated."
    else
        echo "No deactivated NextDNS configuration found. Please configure NextDNS first."
    fi
}

nextdns_activate

