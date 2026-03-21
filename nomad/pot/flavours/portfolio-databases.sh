#!/bin/sh
# PostgreSQL Database Jail Bootstrap

set -e

# Update package manager
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap

# Install PostgreSQL
pkg install -y postgresql14-server postgresql14-contrib

# Create PostgreSQL data directory
mkdir -p /var/lib/postgresql/data/pgdata
chown postgres:postgres /var/lib/postgresql/data/pgdata
chmod 700 /var/lib/postgresql/data/pgdata

# Initialize database cluster
su postgres -c "/usr/local/bin/initdb -D /var/lib/postgresql/data/pgdata"

# Disable rc.d startup (will be managed by Nomad)
sysrc postgresql_enable="NO"

# Configure PostgreSQL for network access
cat > /var/lib/postgresql/data/pgdata/postgresql.conf <<'EOF'
listen_addresses = '0.0.0.0'
port = 5432
max_connections = 200
shared_buffers = 256MB
log_statement = 'all'
log_duration = off
EOF

# Configure host-based authentication
cat > /var/lib/postgresql/data/pgdata/pg_hba.conf <<'EOF'
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             0.0.0.0/0               md5
EOF

chown postgres:postgres /var/lib/postgresql/data/pgdata/postgresql.conf
chown postgres:postgres /var/lib/postgresql/data/pgdata/pg_hba.conf
chmod 600 /var/lib/postgresql/data/pgdata/postgresql.conf
chmod 600 /var/lib/postgresql/data/pgdata/pg_hba.conf

# Clean up
pkg clean -y
