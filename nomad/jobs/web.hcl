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
          "cd /web && node src/server.ts"
        ]
      }

      # Mount source code
      volume_mount {
        volume      = "web_source"
        destination = "/web"
        read_only   = false
      }

      # Environment variables for Next.js
      env {
        NODE_ENV                = "production"
        NODE_OPTIONS            = "--max-old-space-size=512"
        NEXT_TELEMETRY_DISABLED = "1"
      }

      # Template for API URL and runtime configuration
      template {
        data        = <<EOH
API_URL = "http://{{ env "PORTFOLIO_API_HOST" }}:3000"
NEXT_PUBLIC_API_URL = "{{ env "NEXT_PUBLIC_API_URL" }}"
PORT = "${PORT}"
EOH
        destination = "secrets/web.env"
        env         = true
      }

      # Pre-start setup script
      template {
        data        = <<EOH
#!/bin/sh
set -e

WEB_DIR="/web"
cd "$WEB_DIR"

# Install Node dependencies
echo "Installing Node dependencies..."
npm ci --only=production || npm install --production

# Build Next.js application
echo "Building Next.js application..."
npm run build

echo "Web application build complete"
EOH
        destination = "local/setup-web.sh"
      }

      # Service registration
      service {
        name = "portfolio-web"
        port = "web"
        tags = ["web", "nextjs", "frontend", "production"]

        check {
          type     = "http"
          path     = "/"
          port     = "web"
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
  volume "web_source" {
    type      = "host"
    source    = "web_source"
    read_only = false
  }

  # Constraint: Must run on FreeBSD
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

  # Spread load
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
}
