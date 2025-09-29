# Basic Starter Configuration Used for Nomad Course Demonstrations
# This is NOT a Secure Complete Nomad Client Configuration

name = "nomad_client_a"

# Directory to store agent state
data_dir = "/etc/nomad.d/data"

# Address the Nomad agent should bing to for networking
# 0.0.0.0 is the default and results in using the default private network interface
# Any configurations under the addresses parameter will take precedence over this value
bind_addr = "0.0.0.0"

advertise {
  # Defaults to the first private IP address.
  http = "192.168.252.112" # must be reachable by Nomad CLI clients
  rpc  = "192.168.252.112" # must be reachable by Nomad client nodes
  serf = "192.168.252.112" # must be reachable by Nomad server nodes
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
  cert_file = "/etc/certs/global-client-nomad.pem"
  key_file  = "/etc/certs/global-client-nomad-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}

# Specify the datacenter the agent is a member of
datacenter = "dc1"

# Logging Configurations
log_level = "INFO"
log_file  = "/etc/nomad.d/krausen.log"

# Server & Raft configuration
server {
  enabled = false
}

# Client Configuration
client {
  enabled = true

  server_join {
    retry_join = ["192.168.252.107", "192.168.252.108", "192.168.252.109", "192.168.252.110", "192.168.252.111"]
  }
}

consul {
  auto_advertise   = false
  server_auto_join = false
  client_auto_join = false
}
