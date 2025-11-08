#!/bin/bash

LABS_DIR="$HOME/labs"
HOSTS=("192.168.1.20" "192.168.1.30" "192.168.1.40" "192.168.1.50")

send_files() {
    local host=$1
    
    echo "=== Proccesing host: $host ==="
    
    SFTP_SCRIPT=$(mktemp)
    cat > "$SFTP_SCRIPT" << 'EOF'
rm 10/*
rm 5_10/*
rmdir 10
rmdir 5_10
EOF

    cat >> "$SFTP_SCRIPT" << 'EOF'
EOF

    echo "quit" >> "$SFTP_SCRIPT"

    echo "Send file to $host..."
    export SSHPASS=toor
   sshpass -e sftp -o BatchMode=no \
         -o StrictHostKeyChecking=no \
         -o UserKnownHostsFile=/dev/null \
         -o ConnectTimeout=10 \
         -b "$SFTP_SCRIPT" \
         root@"$host"
    
    SFTP_EXIT_CODE=$?
    
    if [ $SFTP_EXIT_CODE -eq 0 ]; then
        echo "✓ Files send succeful $host"
    else
        echo "✗ Error with file send on $host (Code: $SFTP_EXIT_CODE)"
    fi
    
    rm -f "$SFTP_SCRIPT"
}

for host in "${HOSTS[@]}"; do
    if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
        send_files "$host"
    else
        echo "✗ Host $host not found"
    fi
    echo
done

echo "Done"
