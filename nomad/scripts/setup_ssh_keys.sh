#!/bin/bash

# Setup passwordless SSH from nomad_server_a to all other nodes
NODES="192.168.252.108 192.168.252.109 192.168.252.110 192.168.252.111 192.168.252.112 192.168.252.113 192.168.252.114"

echo "Setting up passwordless SSH access..."

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
fi

# Copy public key to each node
for ip in $NODES; do
    echo "Setting up passwordless access to $ip"
    ssh-copy-id root@$ip
done

echo "Done! Test with: ssh root@192.168.252.108"
