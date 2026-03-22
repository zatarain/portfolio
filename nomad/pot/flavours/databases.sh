#!/bin/sh
# PostgreSQL Database Jail Bootstrap - Potluck-based
# Potluck postgresql-nomad base already has PostgreSQL installed
# This script configures PostgreSQL for our needs

set -e

# Disable rc.d startup for PostgreSQL (will be managed by Nomad)
sysrc postgresql_enable="NO" 2>/dev/null || true

# PostgreSQL data directory (inside jail - guaranteed to exist and be writable)
PGDATA="/var/lib/postgresql/data/pgdata"

# Create PostgreSQL data directory
mkdir -p "$PGDATA"
chown postgres:postgres /var/lib/postgresql/data
chown postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

# Initialize database cluster if not already initialized
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "Initializing PostgreSQL cluster at $PGDATA..."
  su postgres -c "/usr/local/bin/initdb -D $PGDATA" || true
fi

# Copy configuration files (created by bootstrap)
if [ -f "/usr/local/etc/pot/flavours/postgresql.conf" ]; then
  cp /usr/local/etc/pot/flavours/postgresql.conf "$PGDATA/postgresql.conf"
  chown postgres:postgres "$PGDATA/postgresql.conf"
  chmod 600 "$PGDATA/postgresql.conf"
fi

if [ -f "/usr/local/etc/pot/flavours/pg_hba.conf" ]; then
  cp /usr/local/etc/pot/flavours/pg_hba.conf "$PGDATA/pg_hba.conf"
  chown postgres:postgres "$PGDATA/pg_hba.conf"
  chmod 600 "$PGDATA/pg_hba.conf"
fi

# Ensure postgres-start.sh exists (bootstrap runs before update-flavours.sh copies it)
# Copy from Potluck flavours or create if missing
if [ -f "/usr/local/etc/pot/flavours/postgres-start.sh" ]; then
  cp /usr/local/etc/pot/flavours/postgres-start.sh /usr/local/bin/postgres-nomad-start
  chmod 755 /usr/local/bin/postgres-nomad-start
fi

echo "✓ PostgreSQL database configuration ready at $PGDATA"
