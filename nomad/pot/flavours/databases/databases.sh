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

# Installing configuration files staged by copy-in
mv /root/*.conf $PGDATA/ 2>/dev/null || true
if [ -f "$PGDATA/postgresql.conf" ]; then
  chown postgres:postgres "$PGDATA/postgresql.conf"
  chmod 600 "$PGDATA/postgresql.conf"
fi

if [ -f "$PGDATA/pg_hba.conf" ]; then
  chown postgres:postgres "$PGDATA/pg_hba.conf"
  chmod 600 "$PGDATA/pg_hba.conf"
fi

if [ -f "/usr/local/bin/postgres-nomad-start" ]; then
  chmod 755 /usr/local/bin/postgres-nomad-start
fi

echo "✓ PostgreSQL database configuration ready at $PGDATA"
