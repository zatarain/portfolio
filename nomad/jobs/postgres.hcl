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

      # Volume mount for persistent data
      volume_mount {
        volume      = "db_data"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      # Environment variables
      env {
        POSTGRES_HOST_AUTH_METHOD = "md5"
        PGDATA                    = "/var/lib/postgresql/data/pgdata"
      }

      # Read secrets from Nomad or local file
      template {
        data        = <<EOH
export POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" }}"
export POSTGRES_USER="{{ env "POSTGRES_USERNAME" }}"
export POSTGRES_DB="portfolio"
EOH
        destination = "local/postgres.env"
        env         = true
      }

      # Host initialization script
      # This sets up the database on first run
      template {
        data        = <<EOH
#!/bin/sh
set -e

PG_VERSION="14"
PG_BIN="/usr/local/bin"
PG_DATA="{{ env "NOMAD_HOST_MOUNT_db_data" }}/pgdata"
POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" }}"
POSTGRES_USERNAME="{{ env "POSTGRES_USERNAME" }}"

# Initialize database if not already done
if [ ! -d "$PG_DATA" ]; then
  echo "Initializing PostgreSQL database..."
  mkdir -p "$PG_DATA"
  chown postgres:postgres "$PG_DATA"
  chmod 700 "$PG_DATA"

  su - postgres -c "${PG_BIN}/initdb -D $PG_DATA"

  # Configure PostgreSQL
  cat >> "$PG_DATA/postgresql.conf" <<EOF
listen_addresses = '0.0.0.0'
port = 5432
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 6600kB
min_wal_size = 1GB
max_wal_size = 4GB
EOF

  # Allow connections from anywhere
  cat > "$PG_DATA/pg_hba.conf" <<EOF
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             0.0.0.0/0               md5
EOF

  # Create portfolio user and database
  su - postgres -c "postgres -D $PG_DATA" &
  POSTGRES_PID=$!
  sleep 2

  su - postgres -c "PGPASSWORD='$POSTGRES_PASSWORD' createuser -P $POSTGRES_USERNAME" || true
  su - postgres -c "createdb -O $POSTGRES_USERNAME portfolio" || true
  su - postgres -c "createdb -O $POSTGRES_USERNAME test-portfolio" || true

  # Enable PostGIS extension
  su - postgres -c "PGPASSWORD='$POSTGRES_PASSWORD' psql -h localhost -U postgres -d portfolio -c 'CREATE EXTENSION IF NOT EXISTS postgis;'" || true

  kill $POSTGRES_PID || true
fi

echo "PostgreSQL initialization complete"
EOH
        destination = "local/init-postgres.sh"
      }

      # Pre-start script to initialize database
      # Note: this runs on the Nomad client, not inside the jail
      # You may need to run initialization manually or adjust for jail context

      # Service registration with Nomad
      service {
        name = "postgres"
        port = "db"
        tags = ["database", "postgresql"]
        check {
          type     = "tcp"
          port     = "db"
          interval = "10s"
          timeout  = "5s"
        }
      }

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

  # Use host volume for database persistence
  volume "db_data" {
    type      = "host"
    source    = "db_data"
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

  # Migration strategy
  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }
}
