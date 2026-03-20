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
