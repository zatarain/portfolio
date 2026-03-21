#!/bin/sh
set -e

API_DIR="/api"
cd "$API_DIR"

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
bundle config set deployment 'true'
bundle install --path vendor/bundle --without test development

# Prepare database
echo "Preparing database..."
bundle exec rake db:create || true
bundle exec rake db:migrate || true

echo "API setup complete"
