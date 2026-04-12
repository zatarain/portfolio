#!/bin/sh
# Next.js Web Jail Bootstrap - Potluck-based
# Using ssl-bootstrap base (Node.js installed here)
# This script prepares the application environment

set -e

# Install Node.js
ASSUME_ALWAYS_YES=yes pkg install -y node25 npm-node25

echo "✓ Next.js application environment ready - waiting for code deployment"
