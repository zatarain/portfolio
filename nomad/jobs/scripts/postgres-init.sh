#!/bin/sh
set -e

PG_VERSION="14"
PG_BIN="/usr/local/bin"
PG_DATA="/var/lib/postgresql/data/pgdata"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-portfolio}"
POSTGRES_USERNAME="${POSTGRES_USERNAME:-portfolio}"

# Initialize database if not already done
if [ ! -d "$PG_DATA" ]; then
  echo "Initializing PostgreSQL database..."
  mkdir -p "$PG_DATA"
  chown postgres:postgres "$PG_DATA"
  chmod 700 "$PG_DATA"

  su postgres -c "${PG_BIN}/initdb -D $PG_DATA"

  # Configure PostgreSQL - look for templates in /tmp first (setup phase) or current dir
  if [ -f "/tmp/postgresql.conf" ]; then
    cp /tmp/postgresql.conf "$PG_DATA/postgresql.conf"
  elif [ -f "./templates/postgresql.conf" ]; then
    cp ./templates/postgresql.conf "$PG_DATA/postgresql.conf"
  fi
  chown postgres:postgres "$PG_DATA/postgresql.conf"
  chmod 640 "$PG_DATA/postgresql.conf" 2>/dev/null || true

  # Allow connections from anywhere
  if [ -f "/tmp/pg_hba.conf" ]; then
    cp /tmp/pg_hba.conf "$PG_DATA/pg_hba.conf"
  elif [ -f "./templates/pg_hba.conf" ]; then
    cp ./templates/pg_hba.conf "$PG_DATA/pg_hba.conf"
  fi
  chown postgres:postgres "$PG_DATA/pg_hba.conf"
  chmod 640 "$PG_DATA/pg_hba.conf" 2>/dev/null || true
fi

echo "PostgreSQL initialization complete"
