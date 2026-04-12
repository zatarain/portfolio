#!/bin/sh
# Environment configuration for Nomad deployment
# Source this file before deploying Nomad jobs

# ============================================
# PostgreSQL Configuration
# ============================================
export POSTGRES_HOST="${POSTGRES_HOST:-databases}"
export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export POSTGRES_USERNAME="${POSTGRES_USERNAME:-portfolio}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-changeme}"

# ============================================
# AWS Configuration (for S3/IAM - if used)
# ============================================
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_ASSUME_ROLE="${AWS_ASSUME_ROLE:-}"
export AWS_SESSION_NAME="${AWS_SESSION_NAME:-api-download-yaml-cv}"

# ============================================
# Instagram Integration (if used)
# ============================================
export INSTAGRAM_CLIENT_ID="${INSTAGRAM_CLIENT_ID:-}"
export INSTAGRAM_CLIENT_SECRET="${INSTAGRAM_CLIENT_SECRET:-}"
export INSTAGRAM_REDIRECT_URI="${INSTAGRAM_REDIRECT_URI:-http://localhost:5000/auth/instagram}"
export INSTAGRAM_ACCESS_TOKEN="${INSTAGRAM_ACCESS_TOKEN:-}"

# ============================================
# Application URLs
# ============================================
export PORTFOLIO_API_HOST="${PORTFOLIO_API_HOST:-localhost}"
export NEXT_PUBLIC_API_URL="${NEXT_PUBLIC_API_URL:-http://localhost:3000}"

# ============================================
# Nomad Configuration
# ============================================
export NOMAD_ADDR="${NOMAD_ADDR:-http://127.0.0.1:4646}"
export NOMAD_REGION="${NOMAD_REGION:-global}"
export NOMAD_DATACENTER="${NOMAD_DATACENTER:-dc1}"

echo "✓ Environment configured"
echo "  Database host: $POSTGRES_HOST"
echo "  API URL: $NEXT_PUBLIC_API_URL"
echo "  Nomad address: $NOMAD_ADDR"
