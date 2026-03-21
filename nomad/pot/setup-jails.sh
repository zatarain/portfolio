#!/bin/sh
# Automated Pot Jail Setup for Portfolio Application
# This script creates and configures jails for PostgreSQL, Rails API, and Next.js frontend

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
  for dataset in portfolio-nginx portfolio-db portfolio-api portfolio-web; do
    if zfs list "$ZPOOL/$dataset" >/dev/null 2>&1; then
      warn "Dataset $ZPOOL/$dataset already exists, skipping"
    else
      log "Creating dataset: $ZPOOL/$dataset"
      zfs create "$ZPOOL/$dataset"
    fi
  done

  # Set mountpoints
  zfs set mountpoint=/data/portfolio-nginx "$ZPOOL/portfolio-nginx" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-db "$ZPOOL/portfolio-db" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-api "$ZPOOL/portfolio-api" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-web "$ZPOOL/portfolio-web" 2>/dev/null || true
}

# Create a single jail
create_jail() {
  local jail_name=$1
  local jail_type=$2

  if pot list | grep -q "^$jail_name$"; then
    warn "Jail $jail_name already exists, skipping"
    return
  fi

  log "Creating $jail_type jail: $jail_name"

  pot create -p "$jail_name" -b 14.3 -t multi -N public-bridge

  # Allocate resources
  case $jail_type in
    "postgres")
      log "Configuring PostgreSQL jail..."
      pot exec -p "$jail_name" pkg update -f
      pot exec -p "$jail_name" pkg install -y postgresql14-server postgresql14-contrib postgis3

      # Stop PostgreSQL (Nomad will manage it)
      pot exec -p "$jail_name" sysrc postgresql_enable=NO
      ;;
    "api")
      log "Configuring API (Rails) jail..."
      pot exec -p "$jail_name" pkg update -f
      pot exec -p "$jail_name" pkg install -y ruby32 ruby32-gems git gmake readline-library
      ;;
    "web")
      log "Configuring Web (Next.js) jail..."
      pot exec -p "$jail_name" pkg update -f
      pot exec -p "$jail_name" pkg install -y node npm
      ;;
    "nginx")
      log "Configuring Nginx (Reverse Proxy) jail..."
      pot exec -p "$jail_name" pkg update -f
      pot exec -p "$jail_name" pkg install -y nginx certbot python3

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
  log "  - portfolio-db (PostgreSQL 14 + PostGIS)"
  log "  - portfolio-api (Ruby 3.2 + Rails)"
  log "  - portfolio-web (Node.js + npm)"
  log ""
  log "ZFS Datasets:"
  log "  - $ZPOOL/portfolio-db → /data/portfolio-db"
  log "  - $ZPOOL/portfolio-api → /data/portfolio-api"
  log "  - $ZPOOL/portfolio-web → /data/portfolio-web"
  log ""
  log "Next steps:"
  log "  1. Configure Nomad: /etc/nomad.d/nomad.hcl"
  log "  2. Start Nomad: service nomad start"
  log "  3. Submit jobs: nomad job run /path/to/portfolio/nomad/jobs/*.hcl (from portfolio directory)"
  log "  4. Configure environment: Create .env.nomad with secrets"
  log "  5. Monitor: nomad job status"
  log ""
  log "Jail commands:"
  log "  - List jails: pot list"
  log "  - Start jail: pot start <name>"
  log "  - Execute in jail: pot exec <name> <command>"
  log "  - Show jail info: pot show <name>"
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
  create_jail "portfolio-nginx" "nginx"
  create_jail "portfolio-db" "postgres"
  create_jail "portfolio-api" "api"
  create_jail "portfolio-web" "web"
  create_health_checks
  print_summary
}

main "$@"
