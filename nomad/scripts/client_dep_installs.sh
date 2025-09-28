#!/bin/bash

# List your SSH config aliases here
CLIENTS=(
    "nomad_client_a"
    "nomad_client_b"
    "nomad_client_c"
)

LOG_DIR="./install_logs"
mkdir -p "$LOG_DIR"

INSTALL_COMMANDS="
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install nomad
sudo dnf update -y
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-\$(arch)-rpms
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install -y ripgrep
sudo dnf install -y jq
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker nomad
sudo mkdir -p /etc/nomad.d
sudo chown nomad:nomad /etc/nomad.d
sudo mkdir -p /etc/nomad.d/data
sudo chown nomad:nomad /etc/nomad.d/data
"

echo "Starting Nomad installation on ${#CLIENTS[@]} clients"
echo "Logs will be saved to: $LOG_DIR"
echo "----------------------------------------"

SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_CLIENTS=()

for server in "${CLIENTS[@]}"; do
    echo "Installing Nomad on: $server"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$INSTALL_COMMANDS" < /dev/null > "$LOG_DIR/${server}.log" 2>&1; then
        echo "✓ SUCCESS: $server"
        ((SUCCESS_COUNT++))
    else
        echo "✗ FAILED: $server (check $LOG_DIR/${server}.log)"
        FAILED_CLIENTS+=("$server")
        ((FAILURE_COUNT++))
    fi
done

echo "----------------------------------------"
echo "Installation Summary:"
echo "✓ Successful: $SUCCESS_COUNT"
echo "✗ Failed: $FAILURE_COUNT"

if [ ${#FAILED_CLIENTS[@]} -gt 0 ]; then
    echo ""
    echo "Failed clients:"
    printf '  %s\n' "${FAILED_CLIENTS[@]}"
    echo ""
    echo "Check individual log files in $LOG_DIR/ for error details"
    exit 1
fi

echo "All installations completed successfully!"
