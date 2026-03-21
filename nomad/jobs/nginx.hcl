job "portfolio-nginx" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100  # High priority - starts first

  group "reverse-proxy" {
    count = 1

    task "nginx" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args = [
          "-c",
          "exec nginx -g 'daemon off;'"
        ]
      }

      # Environment variables
      env {
        NGINX_WORKER_PROCESSES = "auto"
        NGINX_WORKER_CONNECTIONS = "1024"
      }

      # Resource allocation
      resources {
        cpu    = 250
        memory = 256
        network {
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
        }
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

  # Note: Config and certificates are managed within the Pot jail filesystem
  # Update strategy
  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = false
  }

  # Spread across nodes
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
}
