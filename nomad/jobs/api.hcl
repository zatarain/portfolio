job "portfolio-api" {
  datacenters = ["dc1"]
  type        = "service"

  group "backend" {
    count = 1

    # Move network to group level (fixes deprecation warning)
    network {
      mode = "host"
      port "api" {
        static = 3000
      }
    }

    # Task dependency on PostgreSQL
    # In a production setup, use Consul to discover postgres address
    task "api" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args = [
          "-c",
          "exec pot exec -p portfolio-api portfolio-api-run"
        ]
      }

      # Template for sensitive environment variables
      template {
        data        = file("nomad/jobs/scripts/api.env")
        destination = "/data/portfolio-api/.env"
        env         = true
      }

      # Health check - verifies API is responding

      # Resource requirements
      resources {
        cpu    = 1000
        memory = 1024
      }

      # Logging
      logs {
        max_files     = 5
        max_file_size = 50
      }

      # Restart policy
      restart {
        interval = "5m"
        attempts = 3
        delay    = "15s"
        mode     = "fail"
      }
    }
  }


  # Constraint: API must run on same host as PostgreSQL
  # (or adjust based on your networking setup)
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "freebsd"
  }

  # Update strategy
  update {
    max_parallel      = 1
    min_healthy_time  = "30s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = false
  }

  # Spread jobs across available clients
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
}
