#!/bin/bash

# List your SSH config aliases here
NODES=(
    "nomad_server_a"
    "nomad_server_b"
    "nomad_server_c"
    "nomad_server_d"
    "nomad_server_e"
    "nomad_client_a"
    "nomad_client_b"
    "nomad_client_c"
)

LOG_DIR="./restart_logs"
mkdir -p "$LOG_DIR"

RESTART_COMMANDS="
sudo systemctl restart nomad
"

echo "Restarting Nomad service on ${#NODES[@]} nodes"
echo "Logs will be saved to: $LOG_DIR"
echo "----------------------------------------"

SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_NODES=()

for server in "${NODES[@]}"; do
    echo "Restarting Nomad on: $server"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$RESTART_COMMANDS" < /dev/null > "$LOG_DIR/${server}.log" 2>&1; then
        echo "✓ SUCCESS: $server"
        ((SUCCESS_COUNT++))
    else
        echo "✗ FAILED: $server (check $LOG_DIR/${server}.log)"
        FAILED_NODES+=("$server")
        ((FAILURE_COUNT++))
    fi
done

echo "----------------------------------------"
echo "Restart Summary:"
echo "✓ Successful: $SUCCESS_COUNT"
echo "✗ Failed: $FAILURE_COUNT"

if [ ${#FAILED_NODES[@]} -gt 0 ]; then
    echo ""
    echo "Failed nodes:"
    printf '  %s\n' "${FAILED_NODES[@]}"
    echo ""
    echo "Check individual log files in $LOG_DIR/ for error details"
    exit 1
fi

echo "All Nomad services restarted successfully!"
