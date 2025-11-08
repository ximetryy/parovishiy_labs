#!/bin/bash

LABS_DIR="$HOME/labs"
mkdir -p "$LABS_DIR"
echo "Created directory: $LABS_DIR"

for i in {1..5}; do
    # Files >10KB
    dd if=/dev/urandom of="$LABS_DIR/file${i}.sh" bs=1024 count=12 >/dev/null 2>&1
    dd if=/dev/urandom of="$LABS_DIR/file${i}.c" bs=1024 count=12 >/dev/null 2>&1
done

for i in {6..10}; do
    # Files 5-10KB  
    dd if=/dev/urandom of="$LABS_DIR/file${i}.sh" bs=1024 count=7 >/dev/null 2>&1
    dd if=/dev/urandom of="$LABS_DIR/file${i}.c" bs=1024 count=7 >/dev/null 2>&1
done

echo "Files created and filled"

HOSTS=("192.168.1.20" "192.168.1.30" "192.168.1.40" "192.168.1.50")

send_files() {
    local host=$1
    
    echo "=== Proccesing host: $host ==="
    
    SFTP_SCRIPT=$(mktemp)
    cat > "$SFTP_SCRIPT" << 'EOF'
mkdir 10
mkdir 5_10
cd 10
EOF

    for file in "$LABS_DIR"/*; do
        if [[ -f "$file" ]]; then
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
            if [ "$size" -gt 10240 ]; then
                echo "put \"$file\"" >> "$SFTP_SCRIPT"
            fi
        fi
    done

    cat >> "$SFTP_SCRIPT" << 'EOF'
cd ../5_10
EOF

    for file in "$LABS_DIR"/*; do
        if [[ -f "$file" ]]; then
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
            if [ "$size" -ge 5120 ] && [ "$size" -le 10240 ]; then
                echo "put \"$file\"" >> "$SFTP_SCRIPT"
            fi
        fi
    done

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
