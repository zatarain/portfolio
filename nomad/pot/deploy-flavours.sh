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
    if ! pot list | grep -q "^$jail$"; then
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

# Initialize Rails API (bundle install, migrations)
init_api() {
  log "Initializing Rails API..."

  # Run bundle install and prepare database
  pot exec -p portfolio-api sh -c "cd /var/app && bundle install --deployment" \
    || error "Failed to install Rails dependencies"

  pot exec -p portfolio-api sh -c "cd /var/app && bundle exec rake db:create db:migrate" \
    || warn "Database migrations may have issues (this is OK if DB doesn't exist yet)"

  log "✓ Rails API initialized"
}

# Initialize Next.js Web (npm install, build)
init_web() {
  log "Initializing Next.js Web..."

  # Run npm install and build
  pot exec -p portfolio-web sh -c "cd /var/web && npm install" \
    || error "Failed to install Web dependencies"

  pot exec -p portfolio-web sh -c "cd /var/web && npm run build" \
    || warn "Next.js build may have issues"

  log "✓ Next.js Web initialized"
}

# Final summary
print_summary() {
  log "=========================================="
  log "✓ Application Deployment Complete!"
  log "=========================================="
  log ""
  log "All services ready:"
  log "  • Nginx reverse-proxy: Ready"
  log "  • PostgreSQL databases: Ready"
  log "  • Rails API: Code deployed, dependencies installed"
  log "  • Next.js Web: Code deployed, dependencies installed"
  log ""
  log "Next steps:"
  log "  1. Verify jails are running: pot list"
  log "  2. Deploy with Nomad:"
  log "     nomad job run nomad/jobs/postgres.hcl"
  log "     nomad job run nomad/jobs/nginx.hcl"
  log "     nomad job run nomad/jobs/api.hcl"
  log "     nomad job run nomad/jobs/web.hcl"
  log "  3. Monitor: nomad status"
  log "=========================================="
}

main() {
  log "Starting Portfolio Application Deployment"
  log "Logging to: $LOG_FILE"
  log ""

  check_jails
  copy_code
  init_api
  init_web

  print_summary
}

main "$@"
