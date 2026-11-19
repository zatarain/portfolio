#!/bin/sh
# Rails API Jail Bootstrap - Potluck-based
# Using ssl-bootstrap base (Node.js and Ruby installed here)
# This script installs Rails dependencies

set -e

# Install Node.js, Ruby, PostgreSQL client, and build tools
ASSUME_ALWAYS_YES=yes pkg install -y ruby40 ruby40-gems git gmake readline postgresql15-client

echo "✓ Rails API environment ready - waiting for code deployment"
