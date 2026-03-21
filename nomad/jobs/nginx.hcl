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

      # Volume mount for nginx config and SSL certs
      volume_mount {
        volume      = "nginx_config"
        destination = "/usr/local/etc/nginx/conf.d"
        read_only   = false
      }

      volume_mount {
        volume      = "letsencrypt"
        destination = "/usr/local/etc/letsencrypt"
        read_only   = false
      }

      # Environment variables
      env {
        NGINX_WORKER_PROCESSES = "auto"
        NGINX_WORKER_CONNECTIONS = "1024"
      }

      # Service registration
      service {
        name = "nginx"
        port = "http"
        tags = ["reverse-proxy", "web", "production"]

        check {
          type     = "http"
          path     = "/"
          port     = "http"
          interval = "10s"
          timeout  = "5s"
        }
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

  # Host volumes
  volume "nginx_config" {
    type      = "host"
    source    = "nginx_config"
    read_only = false
  }

  volume "letsencrypt" {
    type      = "host"
    source    = "letsencrypt"
    read_only = false
  }

  # Update strategy
  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = true
  }

  # Spread across nodes
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
}
