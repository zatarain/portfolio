#!/bin/sh
# Portfolio Application - Pot Flavour-based Setup with Potluck
# Distinguished engineering approach using Potluck pre-built images + Pot flavours
# This script creates jails from Potluck templates with minimal bootstrap overhead

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/portfolio-setup.log"
POTLUCK_DIR="/tmp/potluck-templates"
POTLUCK_REPO="https://codeberg.org/bsdpot/potluck.git"

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

# Sync Potluck templates repository
sync_potluck_templates() {
  log "Syncing Potluck templates from official repository..."

  if [ -d "$POTLUCK_DIR/.git" ]; then
    log "Updating existing Potluck repository..."
    cd "$POTLUCK_DIR" && git pull origin master 2>/dev/null || \
      warn "Could not update Potluck repo, proceeding with existing version"
    cd - >/dev/null
  else
    log "Cloning Potluck templates repository..."
    mkdir -p "$POTLUCK_DIR"
    git clone "$POTLUCK_REPO" "$POTLUCK_DIR" || \
      error "Failed to clone Potluck repository. Check internet connectivity."
  fi

  log "✓ Potluck templates synced"
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
    error "Failed to create base-$base_version"

  log "✓ base-$base_version created successfully"
}

# Copy Potluck flavours to system location for use
setup_potluck_flavours() {
  log "Setting up Potluck flavours..."

  local POTLUCK_FLAVOURS_SRC="/tmp/potluck-templates"
  local POT_FLAVOURS_DIR="/usr/local/etc/pot/flavours"

  # Function to copy Potluck flavour with its subdirectories
  copy_potluck_flavour() {
    local template_name=$1
    local template_dir="$POTLUCK_FLAVOURS_SRC/$template_name"

    if [ ! -d "$template_dir" ]; then
      return
    fi

    # Copy core flavour files (config, .sh, -cmd)
    [ -f "$template_dir/$template_name" ] && \
      cp "$template_dir/$template_name" "$POT_FLAVOURS_DIR/" 2>/dev/null || true

    [ -f "$template_dir/${template_name}.sh" ] && \
      cp "$template_dir/${template_name}.sh" "$POT_FLAVOURS_DIR/" 2>/dev/null || true

    [ -f "$template_dir/${template_name}-cmd" ] && \
      cp "$template_dir/${template_name}-cmd" "$POT_FLAVOURS_DIR/" 2>/dev/null || true

    # Copy .d subdirectories (if they exist) - these contain additional flavour data
    if [ -d "$template_dir/${template_name}.d" ]; then
      cp -r "$template_dir/${template_name}.d" "$POT_FLAVOURS_DIR/" 2>/dev/null || true
    fi

    log "  ✓ Copied $template_name"
  }

  log "Copying Potluck flavours to $POT_FLAVOURS_DIR..."

  copy_potluck_flavour "postgres-single"
  copy_potluck_flavour "nginx"
  copy_potluck_flavour "nodejs"

  log "✓ Potluck flavours ready"
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

# Create a jail using flavours with optional Potluck template
create_jail_with_flavour() {
  local jail_name=$1
  local potluck_template=$2
  local jail_type=$3
  local zfs_dataset=$4

  if pot show -qp "$jail_name"; then
    log "✓ $jail_type jail $jail_name already exists, skipping"
    return
  fi

  log "Creating $jail_type jail: $jail_name"

  # Build pot create command with flavours
  local cmd="pot create -p $jail_name -b 14.4 -t multi -N inherit"

  # Always add ssl-bootstrap first
  cmd="$cmd -f ssl-bootstrap"

  # Add Potluck template if provided (non-empty and not "none")
  if [ -n "$potluck_template" ] && [ "$potluck_template" != "none" ]; then
    cmd="$cmd -f $potluck_template"
    log "  (using Potluck flavour: $potluck_template)"
  fi

  # Add custom config and startup command
  cmd="$cmd -f $jail_name -f ${jail_name}-cmd"

  # Execute pot create
  eval "$cmd" || error "Failed to create jail $jail_name"

  log "✓ Jail $jail_name created successfully"
}

# Create all jails from Potluck bases
create_jails() {
  log "========================================"
  log "Creating jails with Potluck flavours"
  log "========================================"

  create_jail_with_flavour "reverse-proxy" "nginx" "Nginx" "reverse-proxy"
  create_jail_with_flavour "databases" "postgres-single" "PostgreSQL" "databases"
  create_jail_with_flavour "portfolio-api" "none" "Rails API" "portfolio-api"
  create_jail_with_flavour "portfolio-web" "none" "Next.js Web" "portfolio-web"

  log "✓ All jails created"
}

# Final summary
print_summary() {
  log "=========================================="
  log "✓ Portfolio Infrastructure Setup Complete!"
  log "=========================================="
  log ""
  log "Created jails (with Potluck flavours):"
  log "  • reverse-proxy (Nginx, port 80/443)"
  log "  • databases (PostgreSQL 14, port 5432)"
  log "  • portfolio-api (Rails 7 on Node.js, port 3000)"
  log "  • portfolio-web (Next.js on Node.js, port 5000)"
  log ""
  log "ZFS Datasets:"
  log "  • zroot/reverse-proxy → /data/reverse-proxy"
  log "  • zroot/databases → /data/databases"
  log "  • zroot/portfolio-api → /data/portfolio-api"
  log "  • zroot/portfolio-web → /data/portfolio-web"
  log ""
  log "Architecture:"
  log "  • Base OS: FreeBSD 14.4"
  log "  • Flavour stack (order matters!):"
  log "    1. ssl-bootstrap: Fixes SSL, installs ca_root_nss"
  log "    2. Optional Potluck flavour: nginx, postgres-single"
  log "       (portfolio-api & portfolio-web: Node.js installed in bootstrap)"
  log "    3. Custom config: portfolio-api-, portfolio-web-, databases-, reverse-proxy-"
  log "    4. Startup command: Nomad-managed via -cmd flavours"
  log ""
  log "Jails are configured and ready for:"
  log "  1. Application code deployment"
  log "  2. Nomad orchestration"
  log ""
  log "Next step: ./nomad/pot/deploy-flavours.sh"
  log "=========================================="
}

main() {
  log "Starting Portfolio Infrastructure Setup (Potluck-based)"
  log "Logging to: $LOG_FILE"
  log ""

  check_prerequisites
  check_pot_init
  sync_potluck_templates
  ensure_base_image
  setup_potluck_flavours
  create_zfs_datasets
  create_jails
  print_summary
}

main "$@"
