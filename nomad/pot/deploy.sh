#!/bin/sh
# Deploy Application Code and Complete Initialization
# Run this after creating jails and copying code to ZFS datasets

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
  printf "%s[%s]%s %s\n" "$GREEN" "$(date +'%Y-%m-%d %H:%M:%S')" "$NC" "$1"
}

warn() {
  printf "%s[WARNING]%s %s\n" "$YELLOW" "$NC" "$1"
}

error() {
  printf "%s[ERROR]%s %s\n" "$RED" "$NC" "$1"
  exit 1
}

# Check that jails exist
check_jails() {
  log "Checking jails..."
  for jail in databases portfolio-api portfolio-web reverse-proxy; do
    if ! pot list | grep -q "^$jail$"; then
      error "Jail $jail does not exist. Run setup-jails.sh first."
    fi
  done
  log "All jails found"
}

# Mount ZFS datasets
mount_datasets() {
  log "Mounting ZFS datasets..."

  pot mount-in -p portfolio-api -z zroot/portfolio-api -m /var/app || warn "API dataset may already be mounted"
  pot mount-in -p portfolio-web -z zroot/portfolio-web -m /var/web || warn "Web dataset may already be mounted"

  log "ZFS datasets mounted"
}

# Copy code to ZFS datasets
copy_code() {
  log "Copying application code..."

  # Determine the portfolio directory (parent of parent of this script)
  PORTFOLIO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

  if [ ! -d "$PORTFOLIO_DIR/api" ]; then
    error "API directory not found at $PORTFOLIO_DIR/api"
  fi

  if [ ! -d "$PORTFOLIO_DIR/web" ]; then
    error "Web directory not found at $PORTFOLIO_DIR/web"
  fi

  log "Copying API code to /data/portfolio-api..."
  cp -r "$PORTFOLIO_DIR"/api/* /data/portfolio-api/ || error "Failed to copy API code"

  log "Copying Web code to /data/portfolio-web..."
  cp -r "$PORTFOLIO_DIR"/web/* /data/portfolio-web/ || error "Failed to copy Web code"

  log "Application code copied"
}

# Initialize Rails API
init_api() {
  log "Initializing Rails API..."

  pot exec -p portfolio-api sh /tmp/api-setup.sh || error "Failed to initialize Rails API"

  log "Rails API initialized"
}

# Initialize Next.js Web
init_web() {
  log "Initializing Next.js Web..."

  pot exec -p portfolio-web sh /tmp/web-setup.sh || error "Failed to initialize Next.js Web"

  log "Next.js Web initialized"
}

# Summary
print_summary() {
  log "=========================================="
  log "Application Deployment Complete!"
  log "=========================================="
  log ""
  log "All jails are ready with:"
  log "  - PostgreSQL initialized and configured"
  log "  - Rails API dependencies installed"
  log "  - Next.js dependencies installed and built"
  log ""
  log "Next steps:"
  log "  1. Ensure Nomad is running: sudo service nomad status"
  log "  2. Deploy jobs from portfolio directory:"
  log "     nomad job run nomad/jobs/postgres.hcl"
  log "     nomad job run nomad/jobs/nginx.hcl"
  log "     nomad job run nomad/jobs/api.hcl"
  log "     nomad job run nomad/jobs/web.hcl"
  log "  3. Monitor: nomad job status"
  log "=========================================="
}

# Main
main() {
  log "Starting application deployment..."

  check_jails
  mount_datasets
  copy_code
  init_api
  init_web

  print_summary
}

main "$@"
