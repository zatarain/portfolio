# Nomad + Pot + Jails Setup Guide for Portfolio Application

This guide covers deploying your portfolio application (Rails API, Next.js frontend, PostgreSQL) on FreeBSD using HashiCorp Nomad with Pot and Jails.

## Architecture Overview

```
Nomad Server/Client (FreeBSD Host)
├── API Jail (portfolio-api)
│   ├── Rails + Puma
│   ├── Port: 3000
│   └── Process: raw_exec
├── Web Jail (portfolio-web)
│   ├── Next.js
│   ├── Port: 5000
│   └── Process: raw_exec
└── PostgreSQL Jail (portfolio-db)
    ├── PostgreSQL 14 + PostGIS
    ├── Port: 5432
    └── Process: raw_exec
```

All communication flows through jail network interfaces with ZFS datasets for persistent storage.

## Prerequisites

- FreeBSD 12.4+ or 13+ (tested on 13.2+)
- Pot 0.15.0+ installed (`pkg install pot`)
- ZFS filesystem available
- Root/sudo access
- Internet connectivity to download binaries/packages

## Step 1: Install Nomad on FreeBSD

```bash
# Install Nomad (as of 2026, install latest stable)
pkg install nomad

# Verify installation
nomad version

# Create nomad user and directories
pw useradd nomad -d /var/lib/nomad -m
mkdir -p /var/lib/nomad /etc/nomad.d /var/log/nomad
chown -R nomad:nomad /var/lib/nomad /var/log/nomad
chmod 750 /var/lib/nomad
```

## Step 2: Configure Nomad

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
    path = "/data/portfolio-db"
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

## Step 3: Enable and Start Nomad

```bash
# Enable Nomad in rc.conf
sysrc nomad_enable="YES"
sysrc nomad_config="/etc/nomad.d"

# Start Nomad
service nomad start

# Verify Nomad is running
nomad node status
```

## Step 4: Create ZFS Datasets

```bash
# Determine your ZFS pool (e.g., zroot)
ZPOOL=$(zfs list -H -o name | grep -E '^[^/]+$' | head -1)

# Create datasets for persistent storage
zfs create -o mountpoint=/data/$ZPOOL/$POOL/portfolio-db $ZPOOL/portfolio-db
zfs create -o mountpoint=/data/portfolio-api $ZPOOL/portfolio-api
zfs create -o mountpoint=/data/portfolio-web $ZPOOL/portfolio-web

# Set permissions
chmod 755 /data/portfolio-db
chmod 755 /data/portfolio-api
chmod 755 /data/portfolio-web
```

## Step 5: Create Pot Jails for Your Services

See [pot_setup.sh](./pot_setup.sh) for automated jail creation, or follow manual steps below.

### Manual Jail Creation

#### PostgreSQL Jail
```bash
# Create PostgreSQL jail
pot create -p portfolio-db -b 13.2 -f zfs -t default

# Start jail
pot start portfolio-db

# Install PostgreSQL 14 inside jail
pot exec portfolio-db pkg install -y postgresql14-server postgresql14-contrib postgis3

# Initialize PostgreSQL
pot exec portfolio-db /usr/local/etc/rc.d/postgresql initdb

# Configure PostgreSQL to listen on 0.0.0.0 inside jail (for Nomad to connect)
pot exec portfolio-db sysrc postgresql_enable=YES
```

#### API Jail
```bash
# Create API jail
pot create -p portfolio-api -b 13.2 -f zfs -t default

# Start jail
pot start portfolio-api

# Install dependencies
pot exec portfolio-api pkg install -y ruby32 ruby32-gems git
```

#### Web Jail
```bash
# Create Web jail
pot create -p portfolio-web -b 13.2 -f zfs -t default

# Start jail
pot start portfolio-web

# Install Node.js
pot exec portfolio-web pkg install -y node npm
```

## Step 6: Submit Nomad Jobs

Deploy your services:

```bash
# Deploy PostgreSQL
nomad job run jobs/postgres.hcl

# Deploy API
nomad job run jobs/api.hcl

# Deploy Web frontend
nomad job run jobs/web.hcl

# Verify deployments
nomad job status
nomad alloc status
```

## Step 7: Verify Services

```bash
# Check PostgreSQL connection
psql -h <jail-ip> -U portfolio -d portfolio

# Check API
curl http://localhost:3000/health

# Check Frontend
curl http://localhost:5000
```

## Environment Variables

Create `.env.nomad` in the project root with credentials:

```bash
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

## Networking

Pot jails get network interfaces automatically. To verify:

```bash
# List jails
pot list

# Check jail IP
pot show portfolio-db
```

For inter-jail communication, add to Nomad job DNS resolution or use jail IPs directly (10.0.0.x range typically).

## Persisting PostgreSQL Data

The `jobs/postgres.hcl` mounts `/data/portfolio-db` from the host into the jail at `/var/lib/postgresql/data/pgdata`. This ensures:
- Data persists across job failures
- Backups can be taken from host ZFS dataset
- Easy restore by deploying the job again

## Troubleshooting

### Services won't connect
```bash
# Verify jails are running
pot list
pot status

# Check Nomad logs
tail -f /var/log/nomad/nomad.log

# Check jail logs
pot exec portfolio-api tail -f /var/log/nomad-portfolio-api.log
```

### Database connection refused
```bash
# Verify PostgreSQL is listening
pot exec portfolio-db netstat -an | grep 5432

# Check credentials in Nomad job
nomad job inspect postgres
```

### Port conflicts
```bash
# Find what's using ports
sockstat -l | grep -E '3000|5000|5432'

# Check allocated ports
nomad alloc status <allocation-id>
```

## Rollback/Cleanup

```bash
# Stop a job
nomad job stop portfolio-api

# Remove a job
nomad job run -detach=false portfolio-api

# Stop all jobs
nomad node drain -enable

# Destroy jails (careful!)
pot stop portfolio-db
pot destroy portfolio-db
```

## Next Steps

1. Implement health checks in Nomad jobs
2. Set up log aggregation (Loki/Promtail or CloudWatch)
3. Configure backup strategy for PostgreSQL data
4. Set up monitoring (Prometheus + Grafana)
5. Implement auto-scaling based on metrics
6. Configure Consul for service discovery (optional)

## References

- [Nomad Documentation](https://www.nomadproject.io/docs)
- [Pot Documentation](https://pot.pizzamig.dev/)
- [FreeBSD Jails Handbook](https://docs.freebsd.org/en/books/handbook/jails/)
