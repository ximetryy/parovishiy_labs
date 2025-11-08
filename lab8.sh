#!/bin/bash

# Script to create DNS A records based on hostname and IP
# Usage: ./create_dns_records.sh <hostname> <ip_address> [domain]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default domain
DEFAULT_DOMAIN="local.lan"
ZONE_FILE="/etc/bind/db.$DEFAULT_DOMAIN"
REVERSE_ZONE_FILE="/etc/bind/db.192.168.1"

# Function to display usage
usage() {
    echo "Usage: $0 <hostname> <ip_address> [domain]"
    echo "Example: $0 webserver 192.168.1.20 example.com"
    exit 1
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
        if [[ $i1 -le 255 && $i2 -le 255 && $i3 -le 255 && $i4 -le 255 ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to get reverse zone from IP
get_reverse_zone() {
    local ip=$1
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    echo "$i3.$i2.$i1.in-addr.arpa"
}

# Function to get reverse record
get_reverse_record() {
    local ip=$1
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    echo "$i4"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Check arguments
if [[ $# -lt 2 ]]; then
    usage
fi

HOSTNAME=$1
IP_ADDRESS=$2
DOMAIN=${3:-$DEFAULT_DOMAIN}

# Update zone file path if domain is specified
if [[ -n "$3" ]]; then
    ZONE_FILE="/etc/bind/db.$DOMAIN"
fi

# Validate IP address
if ! validate_ip "$IP_ADDRESS"; then
    echo -e "${RED}Error: Invalid IP address format${NC}"
    exit 1
fi

# Check if zone file exists
if [[ ! -f "$ZONE_FILE" ]]; then
    echo -e "${RED}Error: Zone file $ZONE_FILE not found${NC}"
    echo "Please create the zone file first"
    exit 1
fi

# Generate current timestamp for serial number
CURRENT_DATE=$(date +%Y%m%d)
CURRENT_SERIAL=$(date +%Y%m%d01)

# Backup zone file
cp "$ZONE_FILE" "$ZONE_FILE.backup.$(date +%Y%m%d%H%M%S)"

echo -e "${YELLOW}Creating DNS record for:${NC}"
echo "Hostname: $HOSTNAME.$DOMAIN"
echo "IP Address: $IP_ADDRESS"
echo "Zone File: $ZONE_FILE"

# Check if record already exists
if grep -q "^$HOSTNAME.*IN.*A.*$IP_ADDRESS" "$ZONE_FILE"; then
    echo -e "${YELLOW}Record already exists${NC}"
    exit 0
fi

# Update serial number in zone file
sed -i "s/^\(.*\); Serial/\t\t\t\t${CURRENT_SERIAL}\t; Serial/" "$ZONE_FILE"

# Add A record
echo -e "\n$HOSTNAME    IN      A       $IP_ADDRESS" >> "$ZONE_FILE"

# Check if reverse zone file exists and add PTR record
REVERSE_ZONE=$(get_reverse_zone "$IP_ADDRESS")
REVERSE_RECORD=$(get_reverse_record "$IP_ADDRESS")
REVERSE_ZONE_FILE="/etc/bind/db.$(get_reverse_zone "$IP_ADDRESS" | sed 's/.in-addr.arpa//')"

if [[ -f "$REVERSE_ZONE_FILE" ]]; then
    echo -e "${YELLOW}Adding reverse PTR record...${NC}"
    cp "$REVERSE_ZONE_FILE" "$REVERSE_ZONE_FILE.backup.$(date +%Y%m%d%H%M%S)"
    sed -i "s/^\(.*\); Serial/\t\t\t\t${CURRENT_SERIAL}\t; Serial/" "$REVERSE_ZONE_FILE"
    echo "$REVERSE_RECORD    IN      PTR     $HOSTNAME.$DOMAIN." >> "$REVERSE_ZONE_FILE"
fi

# Validate zone files
echo -e "${YELLOW}Validating zone files...${NC}"
if named-checkzone "$DOMAIN" "$ZONE_FILE"; then
    echo -e "${GREEN}Forward zone validation successful${NC}"
else
    echo -e "${RED}Forward zone validation failed${NC}"
    exit 1
fi

if [[ -f "$REVERSE_ZONE_FILE" ]]; then
    if named-checkzone "$(get_reverse_zone "$IP_ADDRESS")" "$REVERSE_ZONE_FILE"; then
        echo -e "${GREEN}Reverse zone validation successful${NC}"
    else
        echo -e "${RED}Reverse zone validation failed${NC}"
        exit 1
    fi
fi

# Reload BIND configuration
echo -e "${YELLOW}Reloading BIND configuration...${NC}"
if rndc reload; then
    echo -e "${GREEN}BIND configuration reloaded successfully${NC}"
else
    echo -e "${RED}Failed to reload BIND configuration${NC}"
    systemctl restart bind9
fi

echo -e "${GREEN}DNS record created successfully!${NC}"
echo "Record: $HOSTNAME.$DOMAIN -> $IP_ADDRESS"
