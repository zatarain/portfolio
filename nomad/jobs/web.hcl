job "portfolio-web" {
  datacenters = ["dc1"]
  type        = "service"

  group "frontend" {
    count = 1

    task "web" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args = [
          "-c",
          "exec sudo pot exec -p portfolio-web sh -c 'cd /web && node src/server.ts'"
        ]
      }


      # Environment variables for Next.js
      env {
        NODE_ENV                = "production"
        NODE_OPTIONS            = "--max-old-space-size=512"
        NEXT_TELEMETRY_DISABLED = "1"
      }

      # Template for API URL and runtime configuration
      template {
        data        = file("nomad/jobs/scripts/web.env")
        destination = "secrets/web.env"
        env         = true
      }

      # Pre-start setup script
      template {
        data        = file("nomad/jobs/scripts/web-setup.sh")
        destination = "local/setup-web.sh"
      }

      # Resource requirements
      resources {
        cpu    = 500
        memory = 512
        network {
          port "web" {
            static = 5000
            to     = 5000
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

  # Host volume for source code

  # Constraint: Must run on FreeBSD
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

  # Spread load
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
}
