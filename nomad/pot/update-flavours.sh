#!/bin/sh
# Update Pot Flavours from Local Repository
# Run on FreeBSD server: sudo ./nomad/pot/update-flavours.sh
# Assumes repository is cloned locally on FreeBSD

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { printf "%s✓%s %s\n" "$GREEN" "$NC" "$1"; }
warn() { printf "%s⚠%s %s\n" "$YELLOW" "$NC" "$1"; }
error() { printf "%s✗%s %s\n" "$RED" "$NC" "$1"; exit 1; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLAVOURS_SRC="$SCRIPT_DIR/flavours"
FLAVOURS_DST="/usr/local/etc/pot/flavours"

# Verify source exists
[ -d "$FLAVOURS_SRC" ] || error "Flavours directory not found: $FLAVOURS_SRC"

log "Updating Pot Flavours..."
log "Source: $FLAVOURS_SRC"
log "Destination: $FLAVOURS_DST"

# Create destination if needed
mkdir -p "$FLAVOURS_DST" || error "Cannot create $FLAVOURS_DST"

# Copy flavour files (including .d directories)
log "Copying flavour files..."
cp -R -v "$FLAVOURS_SRC"/* "$FLAVOURS_DST/" || error "Failed to copy flavours"

# Set proper permissions
log "Setting permissions..."
chmod 644 "$FLAVOURS_DST"/* 2>/dev/null || warn "Could not set read-only permissions"
chmod 755 "$FLAVOURS_DST"/*.sh 2>/dev/null || warn "Could not make bootstrap scripts executable"

# Verify
log ""
log "Verifying installation..."
ls -lh "$FLAVOURS_DST" | tail -n +2

log ""
log "✓ Flavours updated successfully!"
