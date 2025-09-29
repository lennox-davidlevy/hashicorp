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
echo 'export NOMAD_ADDR=https://127.0.0.1:4646' >> ~/.bashrc
echo 'export NOMAD_CACERT=/etc/certs/nomad-agent-ca.pem' >> ~/.bashrc  
echo 'export NOMAD_CLIENT_CERT=/etc/certs/global-cli-nomad.pem' >> ~/.bashrc
echo 'export NOMAD_CLIENT_KEY=/etc/certs/global-cli-nomad-key.pem' >> ~/.bashrc
echo 'export NOMAD_TOKEN=\"47276946-0bf9-37d3-fdd6-4c764ba87502\"' >> ~/.bashrc
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
