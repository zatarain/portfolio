#!/bin/sh
set -e
mkdir -p /data/reverse-proxy/certs

cp /usr/local/etc/letsencrypt/live/zatara.in/fullchain.pem /data/reverse-proxy/certs/zatara.in.fullchain.pem
cp /usr/local/etc/letsencrypt/live/zatara.in/privkey.pem  /data/reverse-proxy/certs/zatara.in.key

pot exec -p reverse-proxy nginx -s reload

# pfSense+ and Pi-hole deployment script

# --- CONFIGURATION ---
DOMAINS="geogaussian.com"
LE_DIR="/usr/local/etc/letsencrypt/live/${DOMAINS}"

PFSENSE_IP="eratosthenes.geogaussian.net"
PFSENSE_USER="admin"

PIHOLE_IP="gutenberg.geogaussian.net"
PIHOLE_USER="ulises"
# ---------------------

echo "Starting automated certificate deployment..."

# ==========================================
# 1. DEPLOY TO PI-HOLE
# ==========================================
echo "Deploying certificates to Pi-hole (${PIHOLE_IP})..."

# Combine certificate chain and private key for lighttpd/FTL
cat "${LE_DIR}/fullchain.pem" "${LE_DIR}/privkey.pem" > /tmp/pihole.pem

# Copy combined file to Pi-hole temporary space
scp /tmp/pihole.pem ${PIHOLE_USER}@${PIHOLE_IP}:/tmp/pihole.pem

# Securely move the file, set permissions, and restart the web server on Pi-hole
ssh ${PIHOLE_USER}@${PIHOLE_IP} 'sudo mv /tmp/pihole.pem /etc/pihole/pihole.pem && \
                                 sudo chmod 600 /etc/pihole/pihole.pem && \
                                 sudo chown root:root /etc/pihole/pihole.pem && \
                                 sudo systemctl restart pihole-FTL.service'

rm -f /tmp/pihole.pem
echo "Pi-hole deployment complete."

# ==========================================
# 2. DEPLOY TO PFSENSE+
# ==========================================
echo "Deploying certificates to pfSense+ (${PFSENSE_IP})..."

# Securely copy separate cert and key files to pfSense temp directory
scp "${LE_DIR}/fullchain.pem" ${PFSENSE_USER}@${PFSENSE_IP}:/tmp/pfsense.crt
scp "${LE_DIR}/privkey.pem" ${PFSENSE_USER}@${PFSENSE_IP}:/tmp/pfsense.key

# Use pfSense PHP engine to inject into config.xml and reload WebGUI smoothly
ssh ${PFSENSE_USER}@${PFSENSE_IP} 'php /root/scripts/import-certificate.php /tmp/pfsense.crt /tmp/pfsense.key'

# Clean up temp files on pfSense
ssh ${PFSENSE_USER}@${PFSENSE_IP} 'rm -f /tmp/pfsense.crt /tmp/pfsense.key'

echo "pfSense+ deployment complete."
