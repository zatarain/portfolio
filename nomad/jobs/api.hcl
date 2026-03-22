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
          "exec sudo pot exec -p portfolio-api sh -c 'cd /var/app && bundle config set deployment true && bundle install --path vendor/bundle --without test development && bundle exec rake db:create 2>/dev/null || true && bundle exec rake db:migrate 2>/dev/null || true && bundle exec puma -b tcp://0.0.0.0:3000'"
        ]
      }

      # Copy setup script for reference (optional)
      artifact {
        source      = "file:///root/nomad/jobs/scripts/api-setup.sh"
        destination = "local/api-setup.sh"
        mode        = "file"
      }


      # Environment variables for Rails
      env {
        RAILS_ENV           = "production"
        RAILS_LOG_TO_STDOUT = "true"
        RAILS_MAX_THREADS   = "5"
        RAILS_MIN_THREADS   = "2"

        # Database configuration
        POSTGRES_PORT     = "5432"
        POSTGRES_USERNAME = "portfolio"
        # POSTGRES_PASSWORD set via template below
        # POSTGRES_HOST set in constraint or discovered via Consul

        # AWS credentials (for CV/resume upload)
        AWS_ENVIRONMENT = "production"
        AWS_SESSION_NAME = "api-download-yaml-cv"

        # API Port (will be set via PORT env var)
      }

      # Template for sensitive environment variables
      template {
        data        = file("nomad/jobs/scripts/api.env")
        destination = "secrets/api.env"
        env         = true
      }

      # Pre-start setup script
      template {
        data        = file("nomad/jobs/scripts/api-setup.sh")
        destination = "local/setup-api.sh"
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
