#!/bin/sh
# Install Pot Flavours to FreeBSD Server
# Usage: ./install-flavours.sh [remote-host]
# Example: ./install-flavours.sh root@freebsd-server

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLAVOURS_DIR="$SCRIPT_DIR/flavours"
REMOTE_HOST="${1:-localhost}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { printf "%s✓%s %s\n" "$GREEN" "$NC" "$1"; }
warn() { printf "%s⚠%s %s\n" "$YELLOW" "$NC" "$1"; }
error() { printf "%s✗%s %s\n" "$RED" "$NC" "$1"; exit 1; }

# Verify flavours directory exists
[ -d "$FLAVOURS_DIR" ] || error "Flavours directory not found: $FLAVOURS_DIR"

log "Installing Pot Flavours..."
log "Target: $REMOTE_HOST"
log "Flavours: $FLAVOURS_DIR"
log "Destination: /usr/local/etc/pot/flavours/"
log ""

# Create destination directory on remote
ssh "$REMOTE_HOST" "sudo mkdir -p /usr/local/etc/pot/flavours" || \
  error "Failed to create flavours directory on remote"

# Copy all flavour files
scp -r "$FLAVOURS_DIR"/* "$REMOTE_HOST":/tmp/portfolio-flavours/ || \
  error "Failed to copy flavours to remote"

# Move to correct location with sudo
ssh "$REMOTE_HOST" "sudo mv /tmp/portfolio-flavours/* /usr/local/etc/pot/flavours/" || \
  error "Failed to move flavours to /usr/local/etc/pot/flavours/"

# Set proper permissions
ssh "$REMOTE_HOST" "sudo chmod 644 /usr/local/etc/pot/flavours/*" || \
  warn "Could not set permissions"

ssh "$REMOTE_HOST" "sudo chmod 755 /usr/local/etc/pot/flavours/*.sh" || \
  warn "Could not make bootstrap scripts executable"

# Verify
log ""
log "Verifying installation..."
ssh "$REMOTE_HOST" "ls -la /usr/local/etc/pot/flavours/ | grep portfolio"

log ""
log "✓ Pot Flavours installed successfully!"
