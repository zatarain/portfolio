#!/bin/sh
# Portfolio Infrastructure Full Cleanup
# Stops all Nomad jobs, destroys pots, removes datasets
# WARNING: This removes ALL infrastructure - use for testing only!

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { printf "%s✓%s %s\n" "$GREEN" "$NC" "$1"; }
warn() { printf "%s⚠%s %s\n" "$YELLOW" "$NC" "$1"; }
error() { printf "%s✗%s %s\n" "$RED" "$NC" "$1"; exit 1; }

log "Starting Full Infrastructure Cleanup..."
log ""

# Stop Nomad jobs
log "Stopping Nomad jobs..."
nomad job stop postgres 2>/dev/null || warn "postgres job not running"
nomad job stop nginx 2>/dev/null || warn "nginx job not running"
nomad job stop portfolio-api 2>/dev/null || warn "portfolio-api job not running"
nomad job stop portfolio-web 2>/dev/null || warn "portfolio-web job not running"
sleep 2

# Stop pots
log "Stopping pots..."
for pot in reverse-proxy databases portfolio-api portfolio-web; do
  if sudo pot show -qp "$pot" >/dev/null 2>&1; then
    sudo pot stop "$pot" 2>/dev/null || warn "Could not stop pot $pot"
  fi
done
sleep 2

# Destroy pots
log "Destroying pots..."
for pot in reverse-proxy databases portfolio-api portfolio-web; do
  if sudo pot show -qp "$pot" >/dev/null 2>&1; then
    sudo pot destroy -p "$pot" || warn "Could not destroy pot $pot"
  fi
done

# Remove ZFS datasets
log "Removing ZFS datasets..."
for dataset in reverse-proxy databases portfolio-api portfolio-web; do
  if sudo zfs list "zroot/$dataset" >/dev/null 2>&1; then
    sudo zfs destroy "zroot/$dataset" 2>/dev/null || warn "Could not destroy zfs dataset zroot/$dataset"
  fi
done

# Remove mounted directories
log "Cleaning up mounted directories..."
sudo rm -rf /data/reverse-proxy /data/databases /data/portfolio-api /data/portfolio-web 2>/dev/null || warn "Could not remove /data/* directories"

# Remove flavours
log "Removing Pot flavours..."
sudo rm -f /usr/local/etc/pot/flavours/ssl-bootstrap* 2>/dev/null || warn "Could not remove ssl-bootstrap flavour"
sudo rm -f /usr/local/etc/pot/flavours/reverse-proxy* 2>/dev/null || warn "Could not remove reverse-proxy flavour"
sudo rm -f /usr/local/etc/pot/flavours/databases* 2>/dev/null || warn "Could not remove databases flavour"
sudo rm -f /usr/local/etc/pot/flavours/portfolio-api* 2>/dev/null || warn "Could not remove portfolio-api flavour"
sudo rm -f /usr/local/etc/pot/flavours/portfolio-web* 2>/dev/null || warn "Could not remove portfolio-web flavour"
sudo rm -f /usr/local/etc/pot/flavours/*.conf 2>/dev/null || warn "Could not remove config files"
sudo rm -f /usr/local/etc/pot/flavours/postgres-start.sh 2>/dev/null || warn "Could not remove postgres-start.sh"

log ""
log "========================================"
log "✓ Full Cleanup Complete!"
log "========================================"
log ""
log "Next steps for fresh deployment:"
log "  1. ./nomad/pot/update-flavours.sh"
log "  2. ./nomad/pot/setup-jails-flavours.sh"
log "  3. sudo pot start reverse-proxy databases portfolio-api portfolio-web"
log "  4. nomad job run nomad/jobs/*.hcl"
log ""
