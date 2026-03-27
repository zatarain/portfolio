#!/bin/sh
set -e

API_DIR="/opt/custom/var/api"
cd "$API_DIR"

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
bundle config set deployment true
bundle config --global silence_root_warning true
bundle config set path "vendor/bundle"
bundle config set without "test development"
bundle install

# Prepare database
echo "Preparing database..."
bundle exec rake db:create || true
bundle exec rake db:migrate || true

echo "API setup complete"
