job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "database" {
    count = 1

    # Move network to group level (fixes deprecation warning)
    network {
      mode = "host"
      port "db" {
        static = 5432
      }
    }

    task "postgres" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args = [
          "-c",
          "exec sudo pot exec -p databases /usr/local/bin/postgres-nomad-start"
        ]
      }

      # Environment variables
      env {
        POSTGRES_HOST_AUTH_METHOD = "md5"
        PGDATA                    = "/var/lib/postgresql/data/pgdata"
      }

      # Read secrets from Nomad or local file
      template {
        data        = file("nomad/jobs/scripts/postgres.env")
        destination = "local/postgres.env"
        env         = true
      }

      # Resource allocation
      resources {
        cpu    = 500
        memory = 512
      }

      # Logging
      logs {
        max_files     = 3
        max_file_size = 10
      }

      # Restart policy
      restart {
        interval = "5m"
        attempts = 3
        delay    = "25s"
        mode     = "fail"
      }
    }
  }

  # Constraint: Must run on FreeBSD (only one node available anyway)
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "freebsd"
  }

  # Note: Data persistence is handled by ZFS datasets configured in Pot during jail setup
  # Update strategy
  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = false
  }

  # Migration strategy
  migrate {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }
}
