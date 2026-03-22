#!/bin/sh
# Deploy Portfolio Application to Nomad
# This script handles submitting Nomad jobs

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
JOBS_DIR="$SCRIPT_DIR/jobs"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
  printf "%s[*]%s %s\n" "$GREEN" "$NC" "$1"
}

error() {
  printf "%s[!]%s %s\n" "$RED" "$NC" "$1"
  exit 1
}

# Load environment
if [ -f "$SCRIPT_DIR/../pot/env.sh" ]; then
  . "$SCRIPT_DIR/../pot/env.sh"
fi

# Check Nomad is running
log "Checking Nomad connectivity..."
nomad server members >/dev/null 2>&1 || error "Cannot connect to Nomad. Is it running? (nomad server members)"

# Check jobs directory
[ -d "$JOBS_DIR" ] || error "Jobs directory not found: $JOBS_DIR"

# Deploy jobs in order (nginx first for routing)
log "Deploying Nginx Reverse Proxy..."
nomad job run "$JOBS_DIR/nginx.hcl" || error "Failed to deploy Nginx job"
sleep 5

log "Deploying PostgreSQL..."
nomad job run "$JOBS_DIR/postgres.hcl" || error "Failed to deploy PostgreSQL job"
sleep 5

log "Deploying API..."
nomad job run "$JOBS_DIR/api.hcl" || error "Failed to deploy API job"
sleep 5

log "Deploying Web Frontend..."
nomad job run "$JOBS_DIR/web.hcl" || error "Failed to deploy Web job"

# Show status
log ""
log "=========================================="
log "Deployment complete!"
log "=========================================="
nomad job status

log ""
log "Check specific job status:"
log "  nomad job status postgres"
log "  nomad job status portfolio-api"
log "  nomad job status portfolio-web"
log ""
log "View logs:"
log "  nomad alloc logs -f <allocation-id>"
