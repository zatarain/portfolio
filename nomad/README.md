# 📖 README - Nomad Deployment

Complete orchestration setup for portfolio application on FreeBSD using HashiCorp Nomad, Pot, and Jails.

## 👀 Quick Overview

This directory contains everything needed to deploy your portfolio application (Rails API, Next.js frontend, PostgreSQL database) on FreeBSD using Nomad as the orchestrator.

### What's Included

- **Nomad job definitions** (`jobs/*.hcl`) - Service orchestration
- **Deployment scripts** (`scripts/*.sh`) - Setup and automation
- **Configuration templates** (`scripts/templates/*`) - PostgreSQL config files
- **Environment configuration** (`scripts/*.env`) - Credentials and URLs
- **Pot jail setup** (`pot/*.sh`) - Jail initialization
- **Complete documentation** - Guides, architecture, troubleshooting
- **Deployment automation** - One-command deployment

### Key Benefits

✅ **Isolated Services** - Each service runs in separate FreeBSD jail
✅ **Persistent Storage** - PostgreSQL data survives restarts (ZFS-backed)
✅ **Automatic Restarts** - Nomad monitors and restarts failed services
✅ **Health Checks** - Continuous verification that services are healthy
✅ **Easy Updates** - Redeploy updated code without manual intervention
✅ **Resource Management** - CPU and memory limits per service

## � Project Structure

```
nomad/
├── jobs/                          # Nomad job definitions
│   ├── postgres.hcl              # PostgreSQL + PostGIS
│   ├── api.hcl                   # Rails API service
│   └── web.hcl                   # Next.js frontend
├── scripts/                        # Deployment & initialization scripts
│   ├── postgres-init.sh          # Database setup
│   ├── api-setup.sh              # API initialization
│   ├── web-setup.sh              # Frontend build
│   ├── postgres.env              # PostgreSQL env template
│   ├── api.env                   # API env template
│   ├── web.env                   # Web env template
│   └── templates/                # Static configuration
│       ├── postgresql.conf       # PostgreSQL settings
│       └── pg_hba.conf           # Auth rules
├── pot/                            # Pot jail configuration
│   ├── setup-jails.sh            # Jail creation
│   ├── env.sh                    # Environment setup
│   ├── nomad-config-example.hcl
│   └── pot-config-example.conf
├── deploy.sh                       # Main deployment script
└── Documentation
    ├── README.md       (this file)
    ├── SETUP.md                  # Detailed setup guide
    ├── QUICKSTART.md             # Quick deployment
    ├── ARCHITECTURE.md           # System design
    └── TROUBLESHOOT.md           # Issue resolution
```

## �🚀 Getting Started

### 1. Choose Your Path

**Quick Start** (5-10 minutes)
→ [QUICKSTART.md](./QUICKSTART.md) - Step-by-step checklist

**Complete Setup** (30+ minutes, first-time)
→ [SETUP.md](./SETUP.md) - Detailed guide with explanations

**Understanding the System**
→ [ARCHITECTURE.md](./ARCHITECTURE.md) - System design and components

**Troubleshooting**
→ [TROUBLESHOOT.md](./TROUBLESHOOT.md) - Common issues and fixes

### 2. Prerequisites

Before starting, ensure you have:
- FreeBSD 13.2+ installed
- Root/sudo access
- ZFS filesystem available
- Internet connectivity for packages

### 3. Installation (In Order)

```sh
# 1. Navigate to this directory
cd /home/ulises/projects/portfolio/nomad

# 2. Create jails (one-time setup)
sudo sh pot/setup-jails.sh

# 3. Configure Nomad
sudo cp pot/nomad-config-example.hcl /etc/nomad.d/nomad.hcl
# Edit if needed: sudo ee /etc/nomad.d/nomad.hcl

# 4. Start Nomad
sudo sysrc nomad_enable="YES"
sudo service nomad start

# 5. Configure environment
source pot/env.sh  # Load default env vars
# Edit credentials:
# nano ~/.env.nomad

# 6. Deploy services
chmod +x deploy.sh
./deploy.sh
```

That's it! Services should be running.

## 📋 File Organization

```
nomad/
├── SETUP.md              # 📖 Complete setup guide
├── QUICKSTART.md         # ⚡ Fast deployment checklist
├── TROUBLESHOOT.md       # 🔧 Troubleshooting guide
├── ARCHITECTURE.md       # 🏗️ System design document
├── README.md             # 📄 This file
│
├── jobs/                 # 🎯 Nomad job definitions
│   ├── postgres.hcl      # PostgreSQL + PostGIS job
│   ├── api.hcl           # Rails API job
│   └── web.hcl           # Next.js frontend job
│
├── pot/                  # 🔒 Jail management
│   ├── setup-jails.sh    # Create jails (run once)
│   ├── env.sh            # Environment variables
│   ├── nomad-config-example.hcl
│   └── pot-config-example.conf
│
└── deploy.sh             # 🚀 Deploy all services
```

## 🎮 Common Commands

### Deploy & Manage Services

```sh
# Deploy all services
./deploy.sh

# Check service status
nomad job status                          # All jobs
nomad job status portfolio-postgres       # Specific job
nomad alloc status <allocation-id>        # Specific allocation

# View logs
nomad alloc logs -f <allocation-id>       # Follow logs
nomad alloc logs -stderr <allocation-id>  # Show errors

# Stop service
nomad job stop portfolio-api

# Update service (redeploy)
nomad job run jobs/api.hcl
```

### Manage Jails

```sh
pot list                    # Show all jails
pot show portfolio-db       # Show jail details
pot start portfolio-db      # Start jail
pot stop portfolio-db       # Stop jail
pot exec portfolio-db ls    # Run command in jail
```

### Verify Services

```sh
# Check all ports
sockstat -l | grep -E '3000|5000|5432'

# Test API
curl http://localhost:3000/health

# Test Frontend
curl http://localhost:5000/

# Test Database
psql -h localhost -U portfolio -d portfolio -c "SELECT 1;"
```

## 📄 Environment Configuration

Edit `~/.env.nomad` to configure:

```sh
# Database credentials (change from defaults!)
POSTGRES_HOST=portfolio-db
POSTGRES_PORT=5432
POSTGRES_USERNAME=portfolio
POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD

# Application URLs
NEXT_PUBLIC_API_URL=http://localhost:3000

# AWS credentials (if using)
AWS_ACCESS_KEY_ID=your_key_here
AWS_SECRET_ACCESS_KEY=your_secret_here
# ... etc
```

## 📋 Architecture Overview

```
FreeBSD Host
├── Nomad Agent (orchestrator)
│   ├── portfolio-postgres jail (5432)
│   ├── portfolio-api jail (3000)
│   └── portfolio-web jail (5000)
│
└── Persistent Storage
    └── /data/portfolio-db (ZFS dataset)
```

Each service:
- Runs in isolated FreeBSD jail
- Monitored by Nomad
- Auto-restarted on failure
- Logs tracked by Nomad

## 🛙 Updating Code

To deploy code changes:

```sh
# 1. Commit and push changes to your repo
git add .
git commit -m "Update API"
git push

# 2. Pull latest on server
cd /home/ulises/projects/portfolio
git pull

# 3. Redeploy via Nomad
nomad job run nomad/jobs/api.hcl
```

Nomad will:
1. Stop old task gracefully
2. Start new task
3. Run health checks
4. Verify it's responding
5. Complete deployment

## 🔨 Troubleshooting

### Services won't start
```sh
nomad alloc logs <allocation-id>  # See error messages
nomad job plan jobs/postgres.hcl  # Validate job file
```

→ See [TROUBLESHOOT.md](./TROUBLESHOOT.md) for detailed help

### Database connection issues
```sh
# Check PostgreSQL is running
pot exec portfolio-db ps aux | grep postgres

# Test connection
psql -h localhost -U portfolio -d portfolio
```

### Frontend can't reach API
```sh
# Check API is responding
curl http://localhost:3000/health

# Check environment variable
nomad alloc logs <web-allocation-id> | grep API_URL
```

## 🎯 Next Steps

1. **Monitor your deployment** - Check logs and metrics regularly
2. **Set up backups** - Create ZFS snapshots periodically
3. **Add health checks** - Customize endpoints in job files
4. **Scale up** - Add more Nomad clients for redundancy (future)
5. **Configure security** - Set up TLS and firewall rules (future)

## 🆘 Support & Resources

- **Nomad Docs**: https://www.nomadproject.io/docs
- **Pot Docs**: https://pot.pizzamig.dev/
- **FreeBSD Handbook**: https://docs.freebsd.org/
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

## 📝 File Descriptions

| File | Purpose |
|------|---------|
| `SETUP.md` | Complete step-by-step installation guide |
| `QUICKSTART.md` | Fast deployment checklist |
| `TROUBLESHOOT.md` | Solutions for common problems |
| `ARCHITECTURE.md` | System design and technical details |
| `jobs/postgres.hcl` | PostgreSQL 14 + PostGIS job definition |
| `jobs/api.hcl` | Rails API job definition |
| `jobs/web.hcl` | Next.js frontend job definition |
| `pot/setup-jails.sh` | Create jails (one-time setup) |
| `pot/env.sh` | Environment variable configuration |
| `pot/nomad-config-example.hcl` | Nomad agent configuration template |
| `pot/pot-config-example.conf` | Pot configuration template |
| `deploy.sh` | Automatic deployment script |

## 🚀 Deployment Modes

### Development
```sh
# Suitable for local testing
RAILS_ENV=development NODE_ENV=development ./deploy.sh
```

### Production
```sh
# Current setup (single node, auto-restart)
RAILS_ENV=production NODE_ENV=production ./deploy.sh

# Future: Add monitoring, TLS, clustering, backups
```

## ✅ Success Criteria

After deployment, you should have:

- ✅ Nomad UI accessible at http://localhost:4646
- ✅ API responding at http://localhost:3000
- ✅ Frontend loading at http://localhost:5000
- ✅ Database connected at localhost:5432
- ✅ All services showing "running" in `nomad job status`
- ✅ Health checks passing for all services

## 📊 Quick Reference

```sh
# One-liner to check everything
echo "=== Nomad ===" && nomad job status && \
echo "=== Jails ===" && pot list && \
echo "=== Ports ===" && sockstat -l | grep -E '3000|5000|5432' && \
echo "=== Database ===" && psql -h localhost -U portfolio -d portfolio -c "SELECT 1;"
```

---

**Ready to deploy?** → Start with [QUICKSTART.md](./QUICKSTART.md)

**Questions?** → Check [TROUBLESHOOT.md](./TROUBLESHOOT.md)

**Want details?** → Read [ARCHITECTURE.md](./ARCHITECTURE.md)
