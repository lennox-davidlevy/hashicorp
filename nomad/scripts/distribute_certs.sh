#!/bin/bash

# Simple certificate distribution script
SERVERS="192.168.252.108 192.168.252.109 192.168.252.110 192.168.252.111"
CLIENTS="192.168.252.112 192.168.252.113 192.168.252.114"

echo "Distributing server certificates..."
for ip in $SERVERS; do
  echo "Copying to server $ip"
  ssh root@$ip "mkdir -p /etc/certs"
  scp /root/certs/nomad-agent-ca.pem /root/certs/global-server-nomad.pem /root/certs/global-server-nomad-key.pem /root/certs/global-cli-nomad.pem /root/certs/global-cli-nomad-key.pem root@$ip:/etc/certs/
  ssh root@$ip "chown -R nomad:nomad /etc/certs"
  ssh root@$ip "chmod 600 /etc/certs/*"
done

echo "Distributing client certificates..."
for ip in $CLIENTS; do
  echo "Copying to client $ip"
  ssh root@$ip "mkdir -p /etc/certs"
  scp /root/certs/nomad-agent-ca.pem /root/certs/global-client-nomad.pem /root/certs/global-client-nomad-key.pem /root/certs/global-cli-nomad.pem /root/certs/global-cli-nomad-key.pem root@$ip:/etc/certs/
  ssh root@$ip "chown -R nomad:nomad /etc/certs"
  ssh root@$ip "chmod 600 /etc/certs/*"
done

echo "Finally, copying to server_a"
cp /root/certs/nomad-agent-ca.pem /root/certs/global-server-nomad.pem /root/certs/global-server-nomad-key.pem /root/certs/global-cli-nomad.pem /root/certs/global-cli-nomad-key.pem /etc/certs/
chown -R nomad:nomad /etc/certs
chmod 600 /etc/certs/*

echo "Done!"
