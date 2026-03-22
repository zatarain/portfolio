#!/bin/sh
# Portfolio Application Code Deployment
# Deploys application code to jails created with flavours
# Jails are already configured (packages, environments, startup commands)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/portfolio-deploy.log"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
  printf "%s[%s]%s %s\n" "$GREEN" "$(date +'%Y-%m-%d %H:%M:%S')" "$NC" "$1" | tee -a "$LOG_FILE"
}

warn() {
  printf "%s[WARNING]%s %s\n" "$YELLOW" "$NC" "$1" | tee -a "$LOG_FILE"
}

error() {
  printf "%s[ERROR]%s %s\n" "$RED" "$NC" "$1" | tee -a "$LOG_FILE"
  exit 1
}

# Verify all jails exist
check_jails() {
  log "Verifying jails exist..."
  for jail in reverse-proxy databases portfolio-api portfolio-web; do
    if ! pot show -qp "$jail" >/dev/null 2>&1; then
      error "Jail $jail does not exist. Run setup-jails-flavours.sh first."
    fi
  done
  log "✓ All jails verified"
}

# Copy application code to jails
copy_code() {
  log "Deploying application code..."

  # Determine portfolio directory
  PORTFOLIO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

  # Verify source directories exist
  [ -d "$PORTFOLIO_DIR/api" ] || error "API source not found at $PORTFOLIO_DIR/api"
  [ -d "$PORTFOLIO_DIR/web" ] || error "Web source not found at $PORTFOLIO_DIR/web"

  # Copy API code
  log "Copying Rails API code to /data/portfolio-api..."
  cp -r "$PORTFOLIO_DIR"/api/* /data/portfolio-api/ || error "Failed to copy API code"

  # Copy Web code
  log "Copying Next.js Web code to /data/portfolio-web..."
  cp -r "$PORTFOLIO_DIR"/web/* /data/portfolio-web/ || error "Failed to copy Web code"

  log "✓ Application code deployed"
}

# Note: Initialization (bundle install, npm install, migrations) is delegated to Nomad jobs
# This keeps deployment separate from orchestration concerns

# Final summary
print_summary() {
  log "=========================================="
  log "✓ Application Code Deployed!"
  log "=========================================="
  log ""
  log "Application code ready in:"
  log "  • /data/portfolio-api (Rails)"
  log "  • /data/portfolio-web (Next.js)"
  log ""
  log "Next steps:"
  log "  1. Run Nomad jobs (they will initialize on first start):"
  log "     nomad job run nomad/jobs/postgres.hcl"
  log "     nomad job run nomad/jobs/nginx.hcl"
  log "     nomad job run nomad/jobs/api.hcl"
  log "     nomad job run nomad/jobs/web.hcl"
  log "  2. Monitor: nomad status"
  log "=========================================="
}

main() {
  log "Starting Portfolio Application Deployment"
  log "Logging to: $LOG_FILE"
  log ""

  check_jails
  copy_code

  print_summary
}

main "$@"
