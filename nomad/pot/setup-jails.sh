#!/bin/sh
# Automated Pot Jail Setup for Portfolio Application
# This script creates and configures jails for PostgreSQL, Rails API, and Next.js frontend

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JOBS_SCRIPTS_DIR="$(cd "$SCRIPT_DIR/../jobs/scripts" && pwd)"
LOG_FILE="/tmp/pot-setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
  printf "%s[%s]%s %s\n" "$GREEN" "$(date +'%Y-%m-%d %H:%M:%S')" "$NC" "$1" | tee -a "$LOG_FILE"
}

error() {
  printf "%s[ERROR]%s %s\n" "$RED" "$NC" "$1" | tee -a "$LOG_FILE"
  exit 1
}

warn() {
  printf "%s[WARNING]%s %s\n" "$YELLOW" "$NC" "$1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
  log "Checking prerequisites..."

  [ -x "$(command -v pot)" ] || error "pot is not installed. Run: pkg install pot"
  [ -x "$(command -v zfs)" ] || error "ZFS is not available"
  [ "$(id -u)" -eq 0 ] || error "This script must be run as root"

  log "Prerequisites check passed"
}

# Initialize Pot if not already done
initialize_pot() {
  if [ -d "/opt/pot" ]; then
    log "Pot already initialized, skipping"
    return
  fi

  log "Initializing Pot framework..."
  pot init -m || error "Failed to initialize Pot"

  log "Configuring Pot network interface..."

  # Detect the primary network interface (not loopback)
  EXT_IF=$(route -4 get default 2>/dev/null | grep "interface:" | awk '{print $2}')

  if [ -z "$EXT_IF" ]; then
    EXT_IF=$(ifconfig -l | awk '{print $1}')
  fi

  log "Using network interface: $EXT_IF"

  # Update pot config with detected interface
  if [ -f "/usr/local/etc/pot/pot.conf" ]; then
    sed -i '' "s/^POT_EXTIF=.*/POT_EXTIF=$EXT_IF/" /usr/local/etc/pot/pot.conf
    log "Updated pot.conf to use interface: $EXT_IF"
  fi

  log "Pot initialization complete"
}

# Create ZFS datasets for persistent storage
create_zfs_datasets() {
  log "Creating ZFS datasets..."

  ZPOOL=$(zfs list -H -o name | grep -E '^[^/]+$' | head -1)
  [ -z "$ZPOOL" ] && error "No ZFS pool found"

  log "Using ZFS pool: $ZPOOL"

  # Create datasets if they don't exist
  for dataset in reverse-proxy databases portfolio-api portfolio-web; do
    if zfs list "$ZPOOL/$dataset" >/dev/null 2>&1; then
      warn "Dataset $ZPOOL/$dataset already exists, skipping"
    else
      log "Creating dataset: $ZPOOL/$dataset"
      zfs create "$ZPOOL/$dataset"
    fi
  done

  # Set mountpoints
  zfs set mountpoint=/data/reverse-proxy "$ZPOOL/reverse-proxy" 2>/dev/null || true
  zfs set mountpoint=/data/databases "$ZPOOL/databases" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-api "$ZPOOL/portfolio-api" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-web "$ZPOOL/portfolio-web" 2>/dev/null || true
}

# Create a single jail
create_jail() {
  local jail_name=$1
  local jail_type=$2

  if pot list | grep -q "^$jail_name$"; then
    warn "Jail $jail_name already exists, skipping initialization"
    return
  fi

  log "Creating $jail_type jail: $jail_name"

  pot create -p "$jail_name" -b 14.3 -t multi -N inherit

  # Start the jail so we can execute commands inside it
  pot start "$jail_name" || error "Failed to start jail $jail_name"

  # Configure DNS inside the jail
  log "Configuring DNS for jail $jail_name..."
  pot exec -p "$jail_name" sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
  pot exec -p "$jail_name" sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
  pot exec -p "$jail_name" pkg install -y pkg
  pot exec -p "$jail_name" pkg update -f

  # Mount ZFS datasets for persistent storage
  log "Mounting ZFS dataset for jail $jail_name..."
  case $jail_type in
    "postgres")
      pot mount-in -p "$jail_name" -z zroot/databases -m /var/db
      ;;
    "api")
      pot mount-in -p "$jail_name" -z zroot/portfolio-api -m /var/app
      ;;
    "web")
      pot mount-in -p "$jail_name" -z zroot/portfolio-web -m /var/web
      ;;
    "nginx")
      pot mount-in -p "$jail_name" -z zroot/reverse-proxy -m /etc/nginx/conf
      ;;
  esac

  # Install packages and run initialization
  case $jail_type in
    "postgres")
      log "Configuring PostgreSQL jail..."
      pot exec -p "$jail_name" pkg install -y postgresql14-server postgresql14-contrib
      # Try PostGIS - may use different package name in some repos
      pot exec -p "$jail_name" pkg install -y pgsql14-postgis 2>/dev/null \
        || log "Note: PostGIS not installed. It may need manual installation with correct package name."

      # Copy and run PostgreSQL initialization script
      log "Running PostgreSQL initialization..."
      pot copy-in -p "$jail_name" -d "${JOBS_SCRIPTS_DIR}/postgres-init.sh" -m /tmp/postgres-init.sh
      pot copy-in -p "$jail_name" -d "${JOBS_SCRIPTS_DIR}/templates/postgresql.conf" -m /tmp/postgresql.conf
      pot copy-in -p "$jail_name" -d "${JOBS_SCRIPTS_DIR}/templates/pg_hba.conf" -m /tmp/pg_hba.conf
      pot exec -p "$jail_name" sh /tmp/postgres-init.sh || warn "PostgreSQL init script had issues"
      pot exec -p "$jail_name" rm /tmp/postgres-init.sh /tmp/postgresql.conf /tmp/pg_hba.conf

      # Stop PostgreSQL (Nomad will manage it)
      pot exec -p "$jail_name" sysrc postgresql_enable=NO
      ;;
    "api")
      log "Configuring API (Rails) jail..."
      pot exec -p "$jail_name" pkg install -y ruby32 git gmake readline postgresql14-client

      # Copy Rails setup script (will run after code is deployed)
      log "Copying Rails setup script..."
      pot copy-in -p "$jail_name" -d "${JOBS_SCRIPTS_DIR}/api-setup.sh" -m /tmp/api-setup.sh
      pot exec -p "$jail_name" chmod +x /tmp/api-setup.sh

      # Note: Will run init-api.sh after code is deployed
      warn "Rails init will run after code deployment to jails"
      ;;
    "web")
      log "Configuring Web (Next.js) jail..."
      pot exec -p "$jail_name" pkg install -y node npm

      # Copy Next.js setup script (will run after code is deployed)
      log "Copying Next.js setup script..."
      pot copy-in -p "$jail_name" -d "${JOBS_SCRIPTS_DIR}/web-setup.sh" -m /tmp/web-setup.sh
      pot exec -p "$jail_name" chmod +x /tmp/web-setup.sh

      # Note: Will run init-web.sh after code is deployed
      warn "Next.js init will run after code deployment to jails"
      ;;
    "nginx")
      log "Configuring Nginx (Reverse Proxy) jail..."
      pot exec -p "$jail_name" pkg install -y nginx

      # Stop Nginx (Nomad will manage it)
      pot exec -p "$jail_name" sysrc nginx_enable=NO
      ;;
  esac

  log "Jail $jail_name created successfully"
}

# Configure networking for jails
configure_networking() {
  log "Configuring networking for jails..."

  # Get default network interface
  INTERFACE=$(route -4 get default | grep interface | awk '{print $2}')
  log "Using network interface: $INTERFACE"

  # Configure pot network (this is typically done in pot's config)
  log "Jails will use pot's default network configuration"
  log "To customize, edit: /usr/local/etc/pot/pot.conf"
}

# Create health check scripts
create_health_checks() {
  log "Creating health check scripts..."

  mkdir -p /usr/local/etc/pot/hooks

  # Copy health check scripts
  cp "${SCRIPT_DIR}/health-checks/postgres.sh" /usr/local/etc/pot/hooks/postgres.sh
  cp "${SCRIPT_DIR}/health-checks/api.sh" /usr/local/etc/pot/hooks/api.sh
  cp "${SCRIPT_DIR}/health-checks/web.sh" /usr/local/etc/pot/hooks/web.sh

  # Make executable
  chmod +x /usr/local/etc/pot/hooks/postgres.sh
  chmod +x /usr/local/etc/pot/hooks/api.sh
  chmod +x /usr/local/etc/pot/hooks/web.sh

  log "Health check scripts installed"
}

# Summary
print_summary() {
  log "=========================================="
  log "Pot Jails Setup Complete!"
  log "=========================================="
  log ""
  log "Created jails:"
  log "  - databases (PostgreSQL 14 + PostGIS)"
  log "  - portfolio-api (Ruby 3.2 + Rails)"
  log "  - portfolio-web (Node.js + npm)"
  log "  - reverse-proxy (Nginx reverse proxy)"
  log ""
  log "ZFS Datasets (ready for app code):"
  log "  - zroot/databases → /data/databases"
  log "  - zroot/portfolio-api → /data/portfolio-api"
  log "  - zroot/portfolio-web → /data/portfolio-web"
  log "  - zroot/reverse-proxy → /data/reverse-proxy"
  log ""
  log "IMPORTANT: Next Steps"
  log "======================================"
  log "1. Copy application code to FreeBSD server:"
  log "   From Linux: scp -r api/ web/ user@freebsd-server:"
  log ""
  log "2. On FreeBSD, run deployment script:"
  log "   cd /path/to/portfolio"
  log "   ./nomad/pot/deploy.sh"
  log ""
  log "   This will:"
  log "   - Mount ZFS datasets in jails"
  log "   - Copy code to jails"
  log "   - Initialize PostgreSQL"
  log "   - Install Rails and Next.js dependencies"
  log "   - Build Next.js application"
  log ""
  log "3. After deployment, start services:"
  log "   nomad job run nomad/jobs/postgres.hcl"
  log "   nomad job run nomad/jobs/nginx.hcl"
  log "   nomad job run nomad/jobs/api.hcl"
  log "   nomad job run nomad/jobs/web.hcl"
  log ""
  log "4. Monitor:"
  log "   nomad job status"
  log "=========================================="
}

# Main execution
main() {
  log "Starting Pot and FreeBSD Jails setup for Portfolio"
  log "Logging to: $LOG_FILE"

  check_prerequisites
  initialize_pot
  create_zfs_datasets
  configure_networking
  create_jail "reverse-proxy" "nginx"
  create_jail "databases" "postgres"
  create_jail "portfolio-api" "api"
  create_jail "portfolio-web" "web"
  create_health_checks
  print_summary
}

main "$@"
