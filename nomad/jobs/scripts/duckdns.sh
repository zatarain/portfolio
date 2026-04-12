#!/bin/sh

result=$(fetch -q -o - "https://www.duckdns.org/update?domains=utz-gaussian-bsd&token=${DUCKDNS_TOKEN}&ip=")
echo "[$(date)] $result" | tee -a /tmp/duckdns.log
