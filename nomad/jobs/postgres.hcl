job "portfolio-postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "database" {
    count = 1

    task "postgres" {
      driver = "raw_exec"

      config {
        command = "/bin/sh"
        args = [
          "-c",
          "exec su - postgres -c 'postgres -D /var/lib/postgresql/data/pgdata'"
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

      # Host initialization script
      # This sets up the database on first run
      template {
        data        = file("nomad/jobs/scripts/postgres-init.sh")
        destination = "local/init-postgres.sh"
      }

      # Pre-start script to initialize database
      # Note: this runs on the Nomad client, not inside the jail
      # You may need to run initialization manually or adjust for jail context

      # Resource allocation
      resources {
        cpu    = 500
        memory = 512
        network {
          port "db" {
            static = 5432
          }
        }
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
