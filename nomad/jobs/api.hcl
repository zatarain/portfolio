job "portfolio-api" {
  datacenters = ["dc1"]
  type        = "service"

  group "backend" {
    count = 1

    # Task dependency on PostgreSQL
    # In a production setup, use Consul to discover postgres address
    task "api" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args = [
          "-c",
          "cd /api && bundle exec puma -b tcp://0.0.0.0:${PORT}"
        ]
      }

      # Mount source code
      volume_mount {
        volume      = "api_source"
        destination = "/api"
        read_only   = false
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
        data        = <<EOH
POSTGRES_PASSWORD = "{{ env "POSTGRES_PASSWORD" }}"
POSTGRES_HOST = "{{ env "POSTGRES_HOST" }}"
AWS_ACCESS_KEY_ID = "{{ env "AWS_ACCESS_KEY_ID" }}"
AWS_SECRET_ACCESS_KEY = "{{ env "AWS_SECRET_ACCESS_KEY" }}"
AWS_REGION = "{{ env "AWS_REGION" }}"
AWS_ASSUME_ROLE = "{{ env "AWS_ASSUME_ROLE" }}"
INSTAGRAM_CLIENT_ID = "{{ env "INSTAGRAM_CLIENT_ID" }}"
INSTAGRAM_CLIENT_SECRET = "{{ env "INSTAGRAM_CLIENT_SECRET" }}"
INSTAGRAM_REDIRECT_URI = "{{ env "INSTAGRAM_REDIRECT_URI" }}"
INSTAGRAM_ACCESS_TOKEN = "{{ env "INSTAGRAM_ACCESS_TOKEN" }}"
EOH
        destination = "secrets/api.env"
        env         = true
      }

      # Pre-start setup script
      template {
        data        = <<EOH
#!/bin/sh
set -e

API_DIR="/api"
cd "$API_DIR"

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
bundle config set deployment 'true'
bundle install --path vendor/bundle --without test development

# Prepare database
echo "Preparing database..."
bundle exec rake db:create || true
bundle exec rake db:migrate || true

echo "API setup complete"
EOH
        destination = "local/setup-api.sh"
      }

      # Health check
      service {
        name = "portfolio-api"
        port = "api"
        tags = ["api", "rails", "production"]

        check {
          type     = "http"
          path     = "/health"
          port     = "api"
          interval = "10s"
          timeout  = "5s"
        }

        # Deregistration on critical
        check_restart {
          limit           = 3
          grace           = "10s"
        }
      }

      # Resource requirements
      resources {
        cpu    = 1000
        memory = 1024
        network {
          port "api" {
            static = 3000
            to     = 3000
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
  volume "api_source" {
    type      = "host"
    source    = "api_source"
    read_only = false
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
    health_check      = "checks"
    min_healthy_time  = "30s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = true
  }

  # Spread jobs across available clients
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
}
