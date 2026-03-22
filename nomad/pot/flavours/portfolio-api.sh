#!/bin/sh
# Rails API Jail Bootstrap

set -e

# Update package manager
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap

# Install Ruby and dependencies
pkg install -y ruby32 git gmake readline postgresql14-client

# Clean up
pkg clean -y
