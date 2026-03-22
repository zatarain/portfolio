#!/bin/sh
# Portfolio Application - Pot Flavour-based Setup
# Distinguished engineering approach using Pot flavours
# This script creates jails using pre-defined, reusable flavour configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/portfolio-setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
  [ -x "$(command -v pot)" ] || error "pot is not installed"
  [ -x "$(command -v zfs)" ] || error "ZFS is not available"
  [ "$(id -u)" -eq 0 ] || error "This script must be run as root"
  log "✓ Prerequisites met"
}

# Check if Pot is initialized
check_pot_init() {
  if [ ! -d "/opt/pot" ]; then
    error "Pot not initialized. Run: sudo pot init -m"
  fi
  log "✓ Pot framework initialized"
}

# Create base FreeBSD distribution if needed
ensure_base_image() {
  local base_version="14_4"
  local base_release="14.4"

  log "Checking for base-$base_version..."

  if pot list -b | grep -q "^bases: $base_release$"; then
    log "✓ base-$base_version already exists"
    return
  fi

  log "Creating base-$base_version from FreeBSD $base_release..."
  pot create-base -r "$base_release" || \
    error "Failed to create base-$base_version. Try: sudo pot create-base -r $base_release"

  log "✓ base-$base_version created successfully"
}

# Create ZFS datasets for persistent storage
create_zfs_datasets() {
  log "Creating ZFS datasets for application volumes..."

  ZPOOL=$(zfs list -H -o name | grep -E '^[^/]+$' | head -1)
  [ -z "$ZPOOL" ] && error "No ZFS pool found"
  log "Using ZFS pool: $ZPOOL"

  # Define jails and their mount points
  JAILS="reverse-proxy databases portfolio-api portfolio-web"

  for jail in $JAILS; do
    if zfs list "$ZPOOL/$jail" >/dev/null 2>&1; then
      warn "Dataset $ZPOOL/$jail already exists"
    else
      log "Creating dataset: $ZPOOL/$jail"
      zfs create "$ZPOOL/$jail"
    fi
  done

  # Set mountpoints
  zfs set mountpoint=/data/reverse-proxy "$ZPOOL/reverse-proxy" 2>/dev/null || true
  zfs set mountpoint=/data/databases "$ZPOOL/databases" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-api "$ZPOOL/portfolio-api" 2>/dev/null || true
  zfs set mountpoint=/data/portfolio-web "$ZPOOL/portfolio-web" 2>/dev/null || true

  log "✓ ZFS datasets created"
}

# Create a jail using flavours
create_jail_with_flavour() {
  local jail_name=$1
  local flavour_base=$2
  local jail_type=$3
  local zfs_dataset=$4

  if pot list | grep -q "^$jail_name$"; then
    warn "Jail $jail_name already exists, skipping"
    return
  fi

  log "Creating $jail_type jail: $jail_name"

  # Create jail using multi-layer type (like Docker layers)
  # Base freedsd 14.4, with two flavours: config + cmd
  pot create -p "$jail_name" \
    -b 14.4 \
    -t multi \
    -N inherit \
    -f "$flavour_base" \
    -f "${flavour_base}-cmd" \
    || error "Failed to create jail $jail_name"

  # Mount ZFS dataset for persistent data
  log "Mounting ZFS dataset for $jail_name..."
  pot mount-in -p "$jail_name" -z "zroot/$zfs_dataset" -m "/var/db" 2>/dev/null || true

  log "✓ Jail $jail_name created successfully"
}

# Create all jails
create_jails() {
  log "========================================"
  log "Creating jails with flavours"
  log "========================================"

  create_jail_with_flavour "reverse-proxy" "reverse-proxy" "Nginx" "reverse-proxy"
  create_jail_with_flavour "databases" "databases" "PostgreSQL" "databases"
  create_jail_with_flavour "portfolio-api" "portfolio-api" "Rails API" "portfolio-api"
  create_jail_with_flavour "portfolio-web" "portfolio-web" "Next.js Web" "portfolio-web"

  log "✓ All jails created"
}

# Final summary
print_summary() {
  log "=========================================="
  log "✓ Portfolio Infrastructure Setup Complete!"
  log "=========================================="
  log ""
  log "Created jails:"
  log "  • reverse-proxy (Nginx, port 80/443)"
  log "  • databases (PostgreSQL 14, port 5432)"
  log "  • portfolio-api (Rails 7, port 3000)"
  log "  • portfolio-web (Next.js, port 5000)"
  log ""
  log "ZFS Datasets:"
  log "  • zroot/reverse-proxy → /data/reverse-proxy"
  log "  • zroot/databases → /data/databases"
  log "  • zroot/portfolio-api → /data/portfolio-api"
  log "  • zroot/portfolio-web → /data/portfolio-web"
  log ""
  log "Jails are configured with flavours and ready for:"
  log "  1. Application code deployment (deploy.sh)"
  log "  2. Nomad orchestration"
  log ""
  log "Next step: ./nomad/pot/deploy.sh"
  log "=========================================="
}

main() {
  log "Starting Portfolio Infrastructure Setup"
  log "Logging to: $LOG_FILE"
  log ""

  check_prerequisites
  check_pot_init
  ensure_base_image
  create_zfs_datasets
  create_jails
  print_summary
}

main "$@"
