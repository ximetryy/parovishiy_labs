#!/bin/bash

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script need run with root (or sudo)!"
        exit 1
    fi
}

show_interfaces() {
    echo "Current network interface:"
    echo "============================"
    ip -o link show | awk -F': ' '{print $2}'
    echo "============================"
}

select_interface() {
    show_interfaces
    read -p "Enter network interface name (example, eth0, wlan0): " interface
    
    if ! ip link show "$interface" &>/dev/null; then
        echo "Error: interface $interface dont exist!"
        return 1
    fi
    
    echo "Selected interface: $interface"
    return 0
}

toggle_ipv4_routing() {
    echo "Current IPv4 routing state:"
    current_state=$(sysctl -n net.ipv4.ip_forward)
    if [ "$current_state" -eq 1 ]; then
        echo "ENABLED (1)"
    else
        echo "DISABLED (0)"
    fi
    
    read -p "Enable (1) or disable (0) IPv4 routing? [1/0]: " choice
    
    case $choice in
        1)
            sysctl -w net.ipv4.ip_forward=1
            echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf
            sysctl -p /etc/sysctl.d/99-ipforward.conf
            echo "IPv4 routing ENABLED"
            ;;
        0)
            sysctl -w net.ipv4.ip_forward=0
            echo "net.ipv4.ip_forward=0" > /etc/sysctl.d/99-ipforward.conf
            sysctl -p /etc/sysctl.d/99-ipforward.conf
            echo "IPv4 routing DISABLED"
            ;;
        *)
            echo "Wrong choice!"
            ;;
    esac
}

change_ip_address() {
    if ! select_interface; then
        return
    fi
    
    echo "Current IP settings for $interface:"
    ip addr show "$interface"
    
    read -p "Enter new IP-address (example, 192.168.1.100/24): " ip_address
    read -p "Enter default gateway (example, 192.168.1.1): " gateway
    
    if ! [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        echo "Error: Wrong IP-Address format!"
        return
    fi
    
    ip link set "$interface" down
    
    ip addr flush dev "$interface"
    
    ip addr add "$ip_address" dev "$interface"
    
    ip link set "$interface" up
    
    if [ -n "$gateway" ]; then
        ip route add default via "$gateway" dev "$interface"
    fi
    
    echo "IP-Addres succseful changed to $ip_address"
    echo "New settings:"
    ip addr show "$interface"
}

change_mac_address() {
    if ! select_interface; then
        return
    fi
    
    echo "Current MAC-Address for $interface:"
    mac_current=$(ip link show "$interface" | awk '/link\/ether/ {print $2}')
    echo "$mac_current"
    
    read -p "Enter new MAC-Address (example, 00:11:22:33:44:55) or press ENTER to random: " mac_new
    
    if [ -z "$mac_new" ]; then
        
        mac_new=$(printf "02:%02x:%02x:%02x:%02x:%02x" \
                 $((RANDOM % 256)) $((RANDOM % 256)) \
                 $((RANDOM % 256)) $((RANDOM % 256)) \
                 $((RANDOM % 256)))
        echo "Generated random MAC: $mac_new"
    fi
    
    if ! [[ $mac_new =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        echo "Error: wrong MAC-Address format!"
        return
    fi
    
    ip link set "$interface" down
    
    ip link set "$interface" address "$mac_new"
    
    ip link set "$interface" up
    
    echo "MAC-Address succsesful changed:"
    ip link show "$interface" | grep "link/ether"
}

main_menu() {
    while true; do
        echo "=========================================="
        echo "          NETWORK SETTINGS UTIL"
        echo "=========================================="
        echo "1. Enable/disable IPv4 routing"
        echo "2. Change IP-Address"
        echo "3. Change MAC-Address"
        echo "4. Show current network settengs"
        echo "5. Exit"
        echo "=========================================="
        
        read -p "Select operation (1-5): " choice
        
        case $choice in
            1)
                echo
                toggle_ipv4_routing
                ;;
            2)
                echo
                change_ip_address
                ;;
            3)
                echo
                change_mac_address
                ;;
            4)
                echo
                echo "Current network settings:"
                echo "--------------------------"
                ip addr show
                echo "--------------------------"
                echo "Routing table:"
                echo "--------------------------"
                ip route show
                ;;
            5)
                echo "Quiting..."
                exit 0
                ;;
            *)
                echo "Wrong choice"
                ;;
        esac
        
        echo
        read -p "Press ENTER to continue..."
        clear
    done
}

check_root
main_menu
