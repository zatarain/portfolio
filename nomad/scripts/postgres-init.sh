#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
  cp "${SCRIPT_DIR}/templates/postgresql.conf" "$PG_DATA/postgresql.conf"
  chown postgres:postgres "$PG_DATA/postgresql.conf"
  chmod 640 "$PG_DATA/postgresql.conf"

  # Allow connections from anywhere
  cp "${SCRIPT_DIR}/templates/pg_hba.conf" "$PG_DATA/pg_hba.conf"
  chown postgres:postgres "$PG_DATA/pg_hba.conf"
  chmod 640 "$PG_DATA/pg_hba.conf"

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
