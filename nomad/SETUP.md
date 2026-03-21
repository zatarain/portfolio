# 🚀 Nomad + Pot + Jails Setup Guide for Portfolio Application

This guide covers deploying your portfolio application (Rails API, Next.js frontend, PostgreSQL) on FreeBSD using HashiCorp Nomad with Pot and Jails.

## 📋 Architecture Overview

```
Nomad Server/Client (FreeBSD Host)
├── Nginx Jail (reverse-proxy)
│   ├── Nginx Reverse Proxy
│   ├── SSL/TLS Termination
│   └── Ports: 80 (HTTP) & 443 (HTTPS)
├── API Jail (portfolio-api)
│   ├── Rails + Puma
│   ├── Port: 3000
│   └── Process: raw_exec
├── Web Jail (portfolio-web)
│   ├── Next.js
│   ├── Port: 5000
│   └── Process: raw_exec
└── PostgreSQL Jail (databases)
    ├── PostgreSQL 14 + PostGIS
    ├── Port: 5432 (internal only)
    └── Process: raw_exec
```

All communication flows through jail network interfaces with ZFS datasets for persistent storage.

## 📁 File Structure & Scripts

The deployment uses external files instead of inline scripts for maintainability:

### Job Files (`jobs/`)
Each Nomad job definition references external scripts and templates:
- `nginx.hcl` → References `scripts/nginx-setup.sh` and `scripts/nginx.conf`
- `postgres.hcl` → References `scripts/postgres-init.sh` and templates
- `api.hcl` → References `scripts/api-setup.sh`
- `web.hcl` → References `scripts/web-setup.sh`

### Setup Scripts (`scripts/`)
These scripts run during task initialization:
- `nginx-setup.sh` - Configures Nginx reverse proxy with SSL
- `postgres-init.sh` - Initializes PostgreSQL database, creates user/DB, enables PostGIS
- `api-setup.sh` - Installs Ruby dependencies, runs migrations
- `web-setup.sh` - Installs Node dependencies, builds Next.js

### Environment Templates (`scripts/*.env`)
These are populated with Nomad env variables at runtime:
- `postgres.env` - PostgreSQL credentials
- `api.env` - Rails credentials and AWS/Instagram config
- `web.env` - Next.js API URL configuration

### Configuration Templates (`scripts/templates/`)
Static configuration files copied into PostgreSQL:
- `postgresql.conf` - PostgreSQL server settings
- `pg_hba.conf` - Host-based authentication rules

## ✅ Prerequisites

- FreeBSD 12.4+ or 13+ (tested on 13.2+)
- Pot 0.15.0+ installed (`pkg install pot`)
- ZFS filesystem available
- Root/sudo access
- Internet connectivity to download binaries/packages

## 1⃣️⃣ Navigate to Portfolio Directory

```sh
# Assume portfolio/ is your working directory
cd portfolio
pwd  # Verify you're in the right place
```

## 2⃣️⃣ Install Nomad on FreeBSD

```sh
# Install Nomad (as of 2026, install latest stable)
sudo pkg install nomad

# Verify installation
nomad version

# Create nomad user and directories
sudo pw useradd nomad -d /var/lib/nomad -m
sudo mkdir -p /var/lib/nomad /etc/nomad.d /var/log/nomad
sudo chown -R nomad:nomad /var/lib/nomad /var/log/nomad
sudo chmod 750 /var/lib/nomad
```

## 3⃣️⃣ Configure Nomad

Create `/etc/nomad.d/nomad.hcl` for agent configuration:

```hcl
# Nomad server/client configuration for FreeBSD + Pot
data_dir = "/var/lib/nomad"
log_level = "info"

# Server settings (if running as server)
server {
  enabled = true
  bootstrap_expect = 1
  server_join {
    retry_join = ["127.0.0.1:4648"]
  }
}

# Client settings
client {
  enabled = true
  node_class = "freebsd-pot"
  options {
    "driver.raw_exec.enable" = "1"
  }

  # Host volume for persistent data
  host_volume "db_data" {
    path = "/data/databases"
  }

  host_volume "api_source" {
    path = "/home/ulises/projects/portfolio/api"
  }

  host_volume "web_source" {
    path = "/home/ulises/projects/portfolio/web"
  }
}

# Addresses configuration
addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

# Telemetry
telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
```

## 3⃣️⃣ Enable and Start Nomad

```sh
# Enable Nomad in rc.conf (use sudo)
sudo sysrc nomad_enable="YES"
sudo sysrc nomad_config="/etc/nomad.d"

# Start Nomad service
sudo service nomad start

# Verify Nomad is running
sleep 2
nomad node status
```

## 4⃣️⃣ Create Pot Jails and ZFS Datasets

The `portfolio/nomad/pot/setup-jails.sh` script automates this entire step:

```sh
cd portfolio/nomad/pot
sudo sh setup-jails.sh
```

This script will:
- Create 4 jails: reverse-proxy, databases, portfolio-api, portfolio-web
- Setup ZFS datasets at `/data/portfolio-*`
- Install required packages in each jail

Verify creation:
```sh
sudo pot list
```

## 5⃣️⃣ Submit Nomad Jobs

Navigate to portfolio root and deploy services:

```sh
cd portfolio

# Deploy PostgreSQL
nomad job run nomad/jobs/postgres.hcl

# Deploy API
nomad job run nomad/jobs/api.hcl

# Deploy Web frontend
nomad job run nomad/jobs/web.hcl

# Verify deployments
nomad job status
nomad alloc status
```

## 6⃣️⃣ Verify Services

```sh
# Check PostgreSQL connection
psql -h <jail-ip> -U portfolio -d portfolio

# Check API
curl http://localhost:3000/health

# Check Frontend
curl http://localhost:5000
```

## 📄 Environment Variables

Create `.env.nomad` in the project root with credentials:

```sh
# PostgreSQL
POSTGRES_HOST=portfolio-db  # Jail hostname or 10.0.0.x IP
POSTGRES_PORT=5432
POSTGRES_USERNAME=portfolio
POSTGRES_PASSWORD=your_secure_password

# AWS (if using S3 for CV upload)
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
AWS_ASSUME_ROLE=arn:aws:iam::YOUR_ACCOUNT:role/YOUR_ROLE
AWS_SESSION_NAME=api-download-yaml-cv

# Instagram (if using Instagram integration)
INSTAGRAM_CLIENT_ID=your_id
INSTAGRAM_CLIENT_SECRET=your_secret
INSTAGRAM_REDIRECT_URI=http://localhost:5000/auth/instagram
INSTAGRAM_ACCESS_TOKEN=your_token

# Application
RAILS_ENV=production
NODE_ENV=production
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## 🌐 Networking

Pot jails get network interfaces automatically. To verify:

```sh
# List jails
pot list

# Check jail IP
pot show databases
```

For inter-jail communication, add to Nomad job DNS resolution or use jail IPs directly (10.0.0.x range typically).

## 💾 Persisting PostgreSQL Data

The `jobs/postgres.hcl` mounts `/data/databases` from the host into the jail at `/var/lib/postgresql/data/pgdata`. This ensures:
- Data persists across job failures
- Backups can be taken from host ZFS dataset
- Easy restore by deploying the job again

## � Setting Up Nginx Reverse Proxy & External Access

### Deploy Nginx Job

```sh
# Deploy nginx reverse proxy (deploys with priority 100, starts first)
nomad job run jobs/nginx.hcl

# Verify deployment
nomad job status portfolio-nginx
nomad alloc logs -f <nginx-allocation-id>
```

### Configure External DNS with DuckDNS

[DuckDNS](https://www.duckdns.org/) provides free dynamic DNS:

1. **Create DuckDNS Account**
   - Go to https://www.duckdns.org/
   - Sign in with GitHub/Google
   - Add a subdomain (e.g., `zatara`)
   - Note your token

2. **Test DuckDNS Update**
   ```sh
   # Test updating your domain
   curl "https://www.duckdns.org/update?domains=zatara&token=YOUR_TOKEN&verbose=true"

   # Should return "OK"
   ```

3. **Automate DuckDNS Updates**
   ```sh
   # Create cron job to update every 5 minutes
   echo "*/5 * * * * curl 'https://www.duckdns.org/update?domains=zatara&token=YOUR_TOKEN' > /dev/null 2>&1" | crontab -

   # Verify
   crontab -l
   ```

### Configure SSL Certificate with Let's Encrypt

```sh
# Inside nginx jail, request certificate
pot exec reverse-proxy certbot certonly \
  --standalone \
  -d zatara.duckdns.org \
  -d api.zatara.duckdns.org \
  --email your_email@example.com \
  --agree-tos \
  --non-interactive

# Certificate will be at /etc/letsencrypt/live/zatara.duckdns.org/
```

### Configure Router Port Forwarding

Forward ports from your router to your FreeBSD host:

1. **Access Router Admin Panel**
   - Usually at `192.168.1.1` or `192.168.0.1`
   - Login with router credentials

2. **Add Port Forwarding Rules**
   - HTTP: External 80 → Internal 80 (FreeBSD host)
   - HTTPS: External 443 → Internal 443 (FreeBSD host)

3. **Test External Access**
   ```sh
   # From a machine outside your network
   curl https://zatara.duckdns.org/          # Should show your site
   curl https://api.zatara.duckdns.org       # Should show API
   ```

### Nginx Configuration for External Access

The `scripts/nginx.conf` file is configured for:
- HTTP → HTTPS redirect (automatically upgrades connections)
- SSL/TLS 1.2 & 1.3 support
- Security headers (HSTS, X-Frame-Options, etc.)
- Rate limiting to prevent abuse
- API routing to Rails backend
- Frontend routing to Next.js

Routing:
- `zatara.duckdns.org` → Next.js frontend (port 5000)
- `api.zatara.duckdns.org` → Rails API (port 3000)

## �🔨 Troubleshooting

### Services won't connect
```sh
# Verify jails are running
pot list
pot status

# Check Nomad logs
tail -f /var/log/nomad/nomad.log

# Check jail logs
pot exec portfolio-api tail -f /var/log/nomad-portfolio-api.log
```

### Database connection refused
```sh
# Verify PostgreSQL is listening
pot exec databases netstat -an | grep 5432

# Check credentials in Nomad job
nomad job inspect postgres
```

### Port conflicts
```sh
# Find what's using ports
sockstat -l | grep -E '3000|5000|5432'

# Check allocated ports
nomad alloc status <allocation-id>
```

## ↩️ Rollback/Cleanup

```sh
# Stop a job
nomad job stop portfolio-api

# Remove a job
nomad job run -detach=false portfolio-api

# Stop all jobs
nomad node drain -enable

# Destroy jails (careful!)
pot stop databases
pot destroy databases
```

## 🎯 Next Steps

1. Implement health checks in Nomad jobs
2. Set up log aggregation (Loki/Promtail or CloudWatch)
3. Configure backup strategy for PostgreSQL data
4. Set up monitoring (Prometheus + Grafana)
5. Implement auto-scaling based on metrics
6. Configure Consul for service discovery (optional)

## 📈 References

- [Nomad Documentation](https://www.nomadproject.io/docs)
- [Pot Documentation](https://pot.pizzamig.dev/)
- [FreeBSD Jails Handbook](https://docs.freebsd.org/en/books/handbook/jails/)
