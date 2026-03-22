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

# Configure PostgreSQL for network access and application needs
cat > "$PGDATA/postgresql.conf" <<'EOF'
listen_addresses = '0.0.0.0'
port = 5432
max_connections = 200
shared_buffers = 256MB
log_statement = 'all'
log_duration = off
EOF

# Configure host-based authentication
cat > "$PGDATA/pg_hba.conf" <<'EOF'
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             0.0.0.0/0               md5
EOF

chown postgres:postgres "$PGDATA/postgresql.conf"
chown postgres:postgres "$PGDATA/pg_hba.conf"
chmod 600 "$PGDATA/postgresql.conf"
chmod 600 "$PGDATA/pg_hba.conf"

# Ensure postgres-start.sh exists (bootstrap runs before update-flavours.sh copies it)
# Copy from Potluck flavours or create if missing
if [ -f "/usr/local/etc/pot/flavours/postgres-start.sh" ]; then
  cp /usr/local/etc/pot/flavours/postgres-start.sh /usr/local/bin/postgres-nomad-start
  chmod 755 /usr/local/bin/postgres-nomad-start
fi

echo "✓ PostgreSQL database configuration ready at $PGDATA"
