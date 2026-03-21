# Example Nomad Configuration for FreeBSD
#
# Location: /etc/nomad.d/nomad.hcl
# This is the main Nomad agent configuration for FreeBSD

# Name the node
node_name = "portfolio-server-01"

# Enable both server and client functionality
server {
  enabled          = true
  bootstrap_expect = 1
  server_join {
    retry_join = ["127.0.0.1:4648"]
  }
}

client {
  enabled   = true
  node_class = "freebsd-pot"

  # Disable drivers not needed
  options {
    "driver.raw_exec.enable" = "1"
  }

  # Host volumes for persistence
  host_volume "nginx_config" {
    path      = "/data/portfolio-nginx/conf.d"
    read_only = false
  }

  host_volume "letsencrypt" {
    path      = "/data/portfolio-nginx/letsencrypt"
    read_only = false
  }

  host_volume "db_data" {
    path      = "/data/portfolio-db"
    read_only = false
  }

  host_volume "api_source" {
    # UPDATE THIS: Set to your actual portfolio directory
    path      = "/path/to/portfolio/api"
    read_only = false
  }

  host_volume "web_source" {
    # UPDATE THIS: Set to your actual portfolio directory
    path      = "/path/to/portfolio/web"
    read_only = false
  }
}

# Agent configuration
agent {
  data_dir  = "/var/lib/nomad"
  log_level = "info"
}

# Server addresses - all interfaces
addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}

# Port bindings
ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

# Telemetry for monitoring
telemetry {
  collection_interval        = "1s"
  use_node_name              = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}

# TLS disabled for local setup
# For production, enable TLS

# ACL configuration (optional)
# acl {
#   enabled = true
# }

# Consul integration (optional, for service discovery)
# consul {
#   address = "127.0.0.1:8500"
# }
