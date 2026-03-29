job "portfolio-web" {
  datacenters = ["dc1"]
  type        = "service"

  group "frontend" {
    count = 1

    # Move network to group level (fixes deprecation warning)
    network {
      mode = "host"
      port "web" {
        static = 5000
      }
    }

    # In a production setup, use Consul to discover API address
    task "setup" {
      driver = "raw_exec"
      config {
        command = "sh"
        args = [
          "-c",
          "exec cp -f $NOMAD_SECRETS_DIR/web.env /data/portfolio-web/.env"
        ]
      }

      # Template for sensitive environment variables
      template {
        data        = file("nomad/jobs/scripts/web.env")
        destination = "secrets/web.env"
        env         = true
      }

      # Run setup only once at startup
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      # Resource allocation for setup task
      resources {
        cpu    = 250
        memory = 256
      }
    }

    task "web" {
      driver = "raw_exec"

      config {
        command = "sh"
        args = [
          "-c",
          "exec pot exec -p portfolio-web portfolio-web-run"
        ]
      }

      # Template for API URL and runtime configuration
      template {
        data        = file("nomad/jobs/scripts/web.env")
        destination = "secrets/web.env"
        env         = true
      }

      # Resource requirements
      resources {
        cpu    = 500
        memory = 512
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
