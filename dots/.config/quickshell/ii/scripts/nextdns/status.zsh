function nextdns_status() {
    local NM_DIR="/etc/NetworkManager"
    local DNSMASQ_DIR="$NM_DIR/dnsmasq.d"
    local CONFIG_FILE_ACTIVATED="$DNSMASQ_DIR/nextdns.conf"
    local CONFIG_FILE_DEACTIVATED="$DNSMASQ_DIR/.disabled.nextdns.conf"

    if [[ -f "$CONFIG_FILE_ACTIVATED" ]]; then
        echo "NextDNS configuration is currently activated."
    elif [[ -f "$CONFIG_FILE_DEACTIVATED" ]]; then
        echo "NextDNS configuration is currently deactivated."
    else
        echo "No NextDNS configuration found. Please configure NextDNS first."
    fi
}

nextdns_status