#!/bin/sh
# PostgreSQL startup script for Nomad
# Handles initialization and startup of PostgreSQL service

set -e

PGDATA="/var/lib/postgresql/data/pgdata"

# Cleanup stale processes and lock files
rm -f "$PGDATA/postmaster.pid"
pkill -9 -u postgres postgres || true

# Ensure directories exist with correct permissions
mkdir -p "$PGDATA"
chown postgres:postgres /var/lib/postgresql/data
chown postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

# Initialize database cluster if not already initialized
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "Initializing PostgreSQL cluster..."
  su postgres -c "/usr/local/bin/initdb -D $PGDATA"
fi

# Start PostgreSQL
echo "Starting PostgreSQL..."
su postgres -c "postgres -D $PGDATA -c listen_addresses=0.0.0.0"
