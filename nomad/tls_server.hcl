# Basic Starter Configuration Used for Nomad Course Demonstrations
# This is NOT a Secure Complete Nomad Server Configuration

name = "nomad_server_a"

# Directory to store agent state
data_dir = "/etc/nomad.d/data"

# Address the Nomad agent should bing to for networking
# 0.0.0.0 is the default and results in using the default private network interface
# Any configurations under the addresses parameter will take precedence over this value
bind_addr = "0.0.0.0"

advertise {
  # Defaults to the first private IP address.
  http = "192.168.252.107" # must be reachable by Nomad CLI clients
  rpc  = "192.168.252.107" # must be reachable by Nomad client nodes
  serf = "192.168.252.107" # must be reachable by Nomad server nodes
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

# TLS configurations
tls {
  http = true
  rpc  = true

  ca_file   = "/etc/certs/nomad-agent-ca.pem"
  cert_file = "/etc/certs/global-server-nomad.pem"
  key_file  = "/etc/certs/global-server-nomad-key.pem"

  verify_server_hostname = true
  verify_https_client    = true

  rpc_upgrade_mode = true
}

# Specify the datacenter the agent is a member of
datacenter = "dc1"

# Logging Configurations
log_level = "INFO"
log_file  = "/etc/nomad.d/krausen.log"

# Server & Raft configuration
server {
  enabled          = true
  bootstrap_expect = 5
  encrypt          = "Egny+/7JlB5wSKW+MZqWysPBRXZZoB3UWI7bX4AqLzk="

  server_join {
    retry_join = ["192.168.252.107:4648", "192.168.252.108:4648", "192.168.252.109:4648", "192.168.252.110:4648", "192.168.252.111:4648"]
  }
}

# Client Configuration - Node can be Server & Client
client {
  enabled = false
}

acl {
  enabled = true
}
