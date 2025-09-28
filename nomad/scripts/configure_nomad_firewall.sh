#!/bin/bash

# List your SSH config aliases here
SERVERS=(
    "nomad_server_a"
    "nomad_server_b"
    "nomad_server_c"
    "nomad_server_d"
    "nomad_server_e"
    "nomad_client_a"
    "nomad_client_b"
    "nomad_client_c"
)

LOG_DIR="./firewall_logs"
mkdir -p "$LOG_DIR"

FIREWALL_COMMANDS="
sudo firewall-cmd --permanent --add-port=4646/tcp
sudo firewall-cmd --permanent --add-port=4647/tcp
sudo firewall-cmd --permanent --add-port=4648/tcp
sudo firewall-cmd --reload
sudo systemctl restart nomad
"

echo "Starting firewall configuration and Nomad restart on ${#SERVERS[@]} servers"
echo "Logs will be saved to: $LOG_DIR"
echo "----------------------------------------"

SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_SERVERS=()

for server in "${SERVERS[@]}"; do
    echo "Configuring firewall and restarting Nomad on: $server"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$FIREWALL_COMMANDS" < /dev/null > "$LOG_DIR/${server}.log" 2>&1; then
        echo "✓ SUCCESS: $server"
        ((SUCCESS_COUNT++))
    else
        echo "✗ FAILED: $server (check $LOG_DIR/${server}.log)"
        FAILED_SERVERS+=("$server")
        ((FAILURE_COUNT++))
    fi
done

echo "----------------------------------------"
echo "Firewall Configuration Summary:"
echo "✓ Successful: $SUCCESS_COUNT"
echo "✗ Failed: $FAILURE_COUNT"

if [ ${#FAILED_SERVERS[@]} -gt 0 ]; then
    echo ""
    echo "Failed servers:"
    printf '  %s\n' "${FAILED_SERVERS[@]}"
    echo ""
    echo "Check individual log files in $LOG_DIR/ for error details"
    exit 1
fi

echo "All firewall configurations and Nomad restarts completed successfully!"
