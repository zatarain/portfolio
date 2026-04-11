#!/bin/sh
set -e
mkdir -p /data/reverse-proxy/certs

cp /usr/local/etc/letsencrypt/live/zatara.in/fullchain.pem /data/reverse-proxy/certs/zatara.in.fullchain.pem
cp /usr/local/etc/letsencrypt/live/zatara.in/privkey.pem  /data/reverse-proxy/certs/zatara.in.key

pot exec -p reverse-proxy nginx -s reload
