#!/bin/bash

# List your SSH config aliases here
SERVERS=(
    "nomad_server_a"
    "nomad_server_b"
    "nomad_server_c"
    "nomad_server_d"
    "nomad_server_e"
)

LOG_DIR="./install_logs"
mkdir -p "$LOG_DIR"

INSTALL_COMMANDS="
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install nomad
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-\$(arch)-rpms
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install -y ripgrep
sudo mkdir -p /etc/nomad.d
sudo chown nomad:nomad /etc/nomad.d
sudo mkdir -p /etc/nomad.d/data
sudo chown nomad:nomad /etc/nomad.d/data
"

echo "Starting Nomad installation on ${#SERVERS[@]} servers"
echo "Logs will be saved to: $LOG_DIR"
echo "----------------------------------------"

SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_SERVERS=()

for server in "${SERVERS[@]}"; do
    echo "Installing Nomad on: $server"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$INSTALL_COMMANDS" < /dev/null > "$LOG_DIR/${server}.log" 2>&1; then
        echo "✓ SUCCESS: $server"
        ((SUCCESS_COUNT++))
    else
        echo "✗ FAILED: $server (check $LOG_DIR/${server}.log)"
        FAILED_SERVERS+=("$server")
        ((FAILURE_COUNT++))
    fi
done

echo "----------------------------------------"
echo "Installation Summary:"
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

echo "All installations completed successfully!"
