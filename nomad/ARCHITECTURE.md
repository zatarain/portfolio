# Architecture Overview

This document describes the complete architecture for deploying your portfolio application on FreeBSD using Nomad, Pot, and Jails.

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FreeBSD Home Server                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         HashiCorp Nomad (Server + Client)            │   │
│  │                                                       │   │
│  │  Port 4646: HTTP API                                 │   │
│  │  Port 4647: RPC (server-to-server)                   │   │
│  │  Port 4648: Serf (discovery)                         │   │
│  └──────────────────────────────────────────────────────┘   │
│                              │                                │
│                ┌─────────────┼─────────────┐                 │
│                │             │             │                 │
│         ┌──────▼──────┐ ┌───▼──────┐ ┌───▼──────┐          │
│         │   API Jail  │ │  Web     │ │ Database │          │
│         │             │ │  Jail    │ │  Jail    │          │
│         ├─────────────┤ ├──────────┤ ├──────────┤          │
│         │ Rails/Puma  │ │ Node.js/ │ │PostgreSQL│          │
│         │ Port: 3000  │ │ Next.js  │ │ PostGIS  │          │
│         │             │ │ Port:5000│ │ 5432     │          │
│         │ Jail IP:    │ │          │ │          │          │
│         │ 172.16.x.y  │ │ Jail IP: │ │ Jail IP: │          │
│         │             │ │172.16.x.z│ │172.16.x.w│         │
│         └──────┬───────┘ └────┬─────┘ └────┬─────┘          │
│                │              │             │                │
│         ┌──────▼──────┐ ┌─────▼──────┐ ┌───▼──────────┐     │
│         │ /api volume │ │/web volume │ │/data/profile │     │
│         │ (bind mount)│ │(bind mount)│ │ -db (ZFS)    │     │
│         └─────────────┘ └────────────┘ └──────────────┘     │
│                │              │             │                │
│                └──────────────┼─────────────┘                │
│                              │                               │
│         ┌────────────────────┴───────────────────┐           │
│         │                                        │           │
│    ┌────▼──────┐                         ┌──────▼───┐       │
│    │ Host File │                         │ ZFS Pool │       │
│    │ System    │                         │ (zroot)  │       │
│    │           │                         │          │       │
│    │/home/*    │                         │ Datasets:│       │
│    │/api       │                         │- portfolio-db  │
│    │/web       │                         │- portfolio-api │
│    │           │                         │- portfolio-web │
│    └───────────┘                         └──────────┘       │
│                                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     Network Layer                             │
├─────────────────────────────────────────────────────────────┤
│ Pot Network (VNET)       Host Network                        │
│ Bridge: 172.16.0.0/16    127.0.0.1                           │
│ - Jail-to-jail: Direct   Port forwarding: Host ←→ Jails     │
│ - Jail-to-host: NATed    3000, 5000, 5432 exposed           │
└─────────────────────────────────────────────────────────────┘
```

## Service Dependencies

```
┌─────────────┐
│   Frontend  │
│  (Next.js)  │
│   Port 5000 │
└──────┬──────┘
       │ Depends on HTTP calls to:
       │
       ▼
┌─────────────┐         ┌──────────────────┐
│    API      │◄────────┤   PostgreSQL +   │
│   (Rails)   │  Depends │     PostGIS      │
│   Port 3000 │  on      │     Port 5432    │
└─────────────┘         └──────────────────┘
```

## Data Flow

```
User Web Browser
       │
       │ HTTP/HTTPS (port 5000)
       ▼
┌──────────────────┐
│  Next.js Frontend│
│  - Render pages  │
│  - State mgmt    │
└────────┬─────────┘
         │
         │ API calls (port 3000)
         │
         ▼
┌──────────────────┐
│  Rails API       │
│  - Controllers   │
│  - Business logic│
│  - Validation    │
└────────┬─────────┘
         │
         │ SQL queries (port 5432)
         │
         ▼
┌──────────────────────────┐
│  PostgreSQL + PostGIS    │
│  - Data storage          │
│  - Geo-spatial queries   │
└──────────────────────────┘
```

## File Structure

```
/home/ulises/projects/portfolio/
├── api/                          # Rails backend
│   ├── app/
│   ├── config/
│   ├── db/
│   ├── Gemfile
│   ├── config.ru
│   └── ...
├── web/                          # Next.js frontend
│   ├── src/
│   ├── pages/
│   ├── package.json
│   ├── next.config.js
│   └── ...
├── nomad/                        # Nomad orchestration (NEW)
│   ├── SETUP.md                  # Complete setup guide
│   ├── QUICKSTART.md             # Quick-start checklist
│   ├── TROUBLESHOOT.md           # Troubleshooting guide
│   ├── ARCHITECTURE.md           # This file
│   ├── deploy.sh                 # Deployment script
│   ├── jobs/
│   │   ├── postgres.hcl          # PostgreSQL job
│   │   ├── api.hcl               # Rails API job
│   │   └── web.hcl               # Next.js job
│   └── pot/
│       ├── setup-jails.sh        # Jail creation script
│       ├── env.sh                # Environment variables
│       ├── nomad-config-example.hcl
│       └── pot-config-example.conf
├── compose.yml                   # Original Docker Compose (for reference)
├── README.md
└── ...
```

## Process Lifecycle

### On System Boot
1. FreeBSD kernel starts
2. ZFS mounts datasets
3. Nomad agent starts (if enabled in rc.conf)
4. Nomad client discovers no jobs (fresh state)
5. Jails remain in stopped state until Nomad tasks start them

### On First Job Submission
1. User runs `./nomad/deploy.sh`
2. Nomad schedules PostgreSQL job on available client
3. Task starts raw_exec driver
4. PostgreSQL initializes database (first time)
5. Health checks begin passing
6. API job scheduled
7. API connects to database, runs migrations
8. Web job scheduled
9. Web builds and starts serving requests

### Normal Operation
```
Continuous monitoring by Nomad:
Every 10s ─► Health checks run ─► If fail 3x ─► Restart process
             Task logs generated    Task restarted
             Metrics collected      Allocation preserved or rescheduled
```

### On Job Stop
1. User runs `nomad job stop portfolio-api`
2. Running tasks receive SIGTERM
3. Graceful shutdown period (default: 30s)
4. If not stopped, SIGKILL sent
5. Databases maintain persistent data (ZFS dataset)
6. Jails remain at OS level but tasks stop

## Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Host OS | FreeBSD | 13.2+ | Base operating system |
| Orchestration | Nomad | Latest stable | Job scheduling & execution |
| Jails | Pot | 0.15.0+ | Jail management wrapper |
| Filesystem | ZFS | FreeBSD native | Persistent storage |
| Backend | Rails | Latest | Web framework |
| Web Server | Puma | Built-in | Ruby application server |
| Frontend | Next.js | Latest | React framework |
| Node Runtime | Node.js | Latest | JavaScript runtime |
| Database | PostgreSQL | 14 | Primary datastore |
| GIS | PostGIS | 3.x | Geographic data |
| Language | Ruby | 3.2 | Backend language |

## Networking Details

### Jail Network (VNET)
- **Bridge Network**: 172.16.0.0/16 (Pot default)
- **API Jail**: 172.16.0.x
- **Web Jail**: 172.16.0.y
- **Database Jail**: 172.16.0.z
- **Communication**: VNET jails can talk directly
- **NAT**: Outbound traffic NATed through host

### Port Mapping
- **3000** → Host:3000 → API Jail:3000 (Rails)
- **5000** → Host:5000 → Web Jail:5000 (Next.js)
- **5432** → Host:5432 → Database Jail:5432 (PostgreSQL)

### Internal Communication
- API → Database: Direct TCP connection (172.16.0.z:5432)
- Web → API: Configured via `NEXT_PUBLIC_API_URL` env var
- Browser → Web: Host port 5000 forwarded to jail
- Browser → API: Host port 3000 forwarded to jail (if direct)

## Storage Architecture

### Persistent Storage (ZFS Datasets)
```
zroot/
├── portfolio-db
│   └── Mount: /data/portfolio-db
│       └── Contains: PostgreSQL data, indexes, WAL
│
├── portfolio-api
│   └── Mount: /data/portfolio-api
│       └── Contains: Application logs (optional)
│
└── portfolio-web
    └── Mount: /data/portfolio-web
        └── Contains: Build artifacts (optional)
```

### Bind Mounts (Source Code)
```
Host                                Jail
/home/ulises/projects/portfolio/api → /api
/home/ulises/projects/portfolio/web → /web
```

## Security Considerations

### Network Isolation
- Jails provide OS-level isolation (like containers)
- Each jail has separate network namespace (VNET)
- No process can escape jail and run on host

### Data Protection
- PostgreSQL data encrypted at rest (if filesystem encrypted)
- Environment variables with secrets managed by Nomad
- No secrets in source code (use Nomad templates)

### Access Control
- Each jail has separate user/group space
- PostgreSQL requires authentication (md5/scram-sha-256)
- Rails environment variables restrict data access

## High Availability Considerations

### Current Setup (Single Node)
- Single Nomad server/client
- Single deployment
- No redundancy
- Suitable for home server

### Future Scaling (Within Nomad)
To scale to multiple nodes:
1. Set `bootstrap_expect = 3` (multiple servers)
2. Configure `server_join` to other Nomad servers
3. Add more Nomad client nodes
4. Configure persistent PostgreSQL replication
5. Set up load balancing (reverse proxy)

## Backup Strategy

### Data Backups (ZFS Snapshots)
```bash
# Manual snapshot
zfs snapshot zroot/portfolio-db@backup-$(date +%s)

# Automated snapshot (add to cron)
*/6 * * * * zfs snapshot zroot/portfolio-db@auto-$(/bin/date +\%s)

# List snapshots
zfs list -t snapshot

# Restore from snapshot
zfs rollback zroot/portfolio-db@backup-123456789
```

### Application Backups
- Source code in git repository
- Nomad job definitions versioned (in nomad/ directory)

### Full System Backup
```bash
# ZFS send to file
zfs send -R zroot/portfolio-db | gzip > /backup/portfolio-db.zfs.gz

# Send to remote (with ssh)
zfs send -R zroot/portfolio-db | ssh remote "zfs recv tank/backups/..."
```

## Performance Tuning

### PostgreSQL Optimization
In `postgres.hcl`, the initialization script sets:
- `shared_buffers = 256MB` (25-40% of RAM)
- `effective_cache_size = 1GB`
- `work_mem = 6600kB`
- `maintenance_work_mem = 64MB`

Adjust based on available system RAM.

### Rails Optimization
In `api.hcl`:
- `RAILS_MAX_THREADS = 5` (connection pool)
- `RAILS_MIN_THREADS = 2`
- CPU: 1000 millicores (1 vCPU equivalent)
- Memory: 1024 MB

### Next.js Optimization
In `web.hcl`:
- `NODE_OPTIONS = --max-old-space-size=512`
- CPU: 500 millicores
- Memory: 512 MB

## Monitoring & Logging

### Nomad Metrics (Built-in)
- Accessible at `http://localhost:4646/v1/agent/metrics`
- Prometheus format: `http://localhost:4646/v1/metrics`
- Includes: CPU, memory, disk usage per allocation

### Application Logs
- Rails: Via stdout (captured by Nomad)
- Next.js: Via stdout and /web/logs/
- PostgreSQL: Via /var/log/ in jail

### Log Aggregation (Future Enhancement)
Consider adding:
- Loki + Promtail (lightweight)
- EFK stack (more features)
- CloudWatch/Datadog (external service)

## Disaster Recovery

### Failure Scenarios

#### Database Corruption
1. Stop API/Web jobs: `nomad job stop portfolio-api portfolio-web`
2. Rollback ZFS snapshot: `zfs rollback zroot/portfolio-db@backup-123456789`
3. Restart jobs: `nomad job run jobs/*.hcl`

#### Complete Jail Failure
1. Destroy failed jail: `pot destroy portfolio-db`
2. Recreate from scratch: `sudo bash nomad/pot/setup-jails.sh`
3. Resubmit Nomad job (data persists in ZFS)

#### System Failure / Power Loss
1. Boot system normally
2. ZFS mounts automatically
3. Nomad agent starts and resumes jobs
4. Services come back online automatically

## Documentation Map

- **SETUP.md** - Complete installation and configuration guide
- **QUICKSTART.md** - Step-by-step deployment checklist
- **TROUBLESHOOT.md** - Common issues and solutions
- **ARCHITECTURE.md** - This file (system design)
- **jobs/*.hcl** - Individual service job definitions
- **pot/env.sh** - Environment variables template
- **deploy.sh** - Automated deployment script

---

**Last Updated:** March 2026
**Suitable For:** FreeBSD 13.2+, Home Server Environment
**Main Services:** Rails API, Next.js Frontend, PostgreSQL with PostGIS
