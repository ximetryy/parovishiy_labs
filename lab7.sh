#!/bin/bash

# Configuration
GATEWAY="192.168.1.1"
NETWORK="192.168.1.0/24"
SSH_USER="user"
SSH_PASS="resu"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Network Scanner & SSH Connector"
    echo "=========================================="
    echo -e "${NC}"
}

# Function to scan network and find available IPs
scan_network() {
    echo -e "${YELLOW}Scanning network $NETWORK...${NC}"
    echo "This may take a few moments..."
    echo
    
    # Use nmap to scan the network and extract live hosts
    mapfile -t available_ips < <(nmap -sn $NETWORK | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v "Nmap" | grep -v "$GATEWAY")
    
    # Also include the gateway if it's up
    if ping -c 1 -W 1 $GATEWAY &> /dev/null; then
        available_ips=("$GATEWAY" "${available_ips[@]}")
    fi
    
    # Sort IP addresses
    IFS=$'\n' sorted_ips=($(sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n <<< "${available_ips[*]}"))
    unset IFS
    
    available_ips=("${sorted_ips[@]}")
}

# Function to display available IPs
show_available_ips() {
    if [ ${#available_ips[@]} -eq 0 ]; then
        echo -e "${RED}No available IP addresses found!${NC}"
        echo "Please check your network connection and try again."
        return 1
    fi
    
    echo -e "${GREEN}Available IP addresses:${NC}"
    echo "------------------------"
    for i in "${!available_ips[@]}"; do
        echo "$((i+1)). ${available_ips[$i]}"
    done
    echo "------------------------"
    return 0
}

# Function to connect via SSH
connect_ssh() {
    local ip=$1
    echo -e "${YELLOW}Connecting to $ip via SSH...${NC}"
    echo "User: $SSH_USER"
    echo "Password: $SSH_PASS"
    echo
    
    # Check if SSH is available on the target
    if nmap -p 22 $ip | grep -q "open"; then
        echo -e "${GREEN}SSH port is open on $ip${NC}"
        echo "Connecting..."
        echo
        
        # Connect using sshpass to automatically provide password
        if command -v sshpass &> /dev/null; then
            sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$ip"
        else
            echo -e "${RED}sshpass is not installed.${NC}"
            echo "You can install it with: sudo apt-get install sshpass"
            echo "Or connect manually with: ssh $SSH_USER@$ip"
            echo "Password: $SSH_PASS"
            ssh -o StrictHostKeyChecking=no "$SSH_USER@$ip"
        fi
    else
        echo -e "${RED}SSH port (22) is not open on $ip${NC}"
        echo "Cannot establish SSH connection."
        read -p "Press Enter to continue..."
    fi
}

# Function to show main menu
show_menu() {
    show_header
    echo "Main Menu:"
    echo "1. Scan Network for Available IPs"
    echo "2. Connect to IP via SSH"
    echo "3. Exit"
    echo
    read -p "Please select an option [1-3]: " main_choice
}

# Function to show SSH connection menu
show_ssh_menu() {
    if [ ${#available_ips[@]} -eq 0 ]; then
        echo -e "${RED}No IP addresses available. Please scan the network first.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    show_header
    show_available_ips
    echo
    read -p "Select IP address to connect [1-${#available_ips[@]}], or 'b' to go back: " ip_choice
    
    if [[ "$ip_choice" == "b" || "$ip_choice" == "B" ]]; then
        return 1
    fi
    
    if [[ "$ip_choice" =~ ^[0-9]+$ ]] && [ "$ip_choice" -ge 1 ] && [ "$ip_choice" -le ${#available_ips[@]} ]; then
        selected_ip="${available_ips[$((ip_choice-1))]}"
        connect_ssh "$selected_ip"
    else
        echo -e "${RED}Invalid selection!${NC}"
        read -p "Press Enter to continue..."
    fi
}

# Main script execution
main() {
    # Check if nmap is installed
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}Error: nmap is not installed.${NC}"
        echo "Please install it with: sudo apt-get install nmap"
        exit 1
    fi
    
    # Check if we're on the correct network
    if ! ip route | grep -q "192.168.10"; then
        echo -e "${YELLOW}Warning: You may not be on the 192.168.10.0/24 network${NC}"
        echo "Current network configuration:"
        ip addr show | grep inet | grep -v 127.0.0.1
        echo
        read -p "Continue anyway? [y/N]: " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    # Initialize available_ips array
    declare -a available_ips
    
    while true; do
        show_menu
        
        case $main_choice in
            1)
                scan_network
                show_header
                if show_available_ips; then
                    echo -e "${GREEN}Scan completed! Found ${#available_ips[@]} available IPs.${NC}"
                else
                    echo -e "${RED}Scan completed but no IPs found.${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            2)
                while true; do
                    show_ssh_menu
                    if [ $? -ne 0 ]; then
                        break
                    fi
                done
                ;;
            3)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option! Please select 1, 2, or 3.${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run the main function
main
