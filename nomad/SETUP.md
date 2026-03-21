# 🚀 Portfolio Infrastructure on FreeBSD with Pot & Nomad

**Architecture: Distinguished Engineering with Pot Flavours**

This document describes the architecture and setup of portfolio services on FreeBSD using Pot jails and Nomad orchestration.

## 📋 System Architecture

### Jails & Services

```
FreeBSD Host (14.3+)
├── ZFS Pool (zroot)
├── Nomad Orchestrator (running on host)
│
└── Pot Jails (created from flavours):
    ├── reverse-proxy (Nginx reverse proxy, inherit network)
    ├── databases (PostgreSQL 14, inherit network)
    ├── portfolio-api (Rails 7 + Puma, inherit network)
    └── portfolio-web (Next.js + Node, inherit network)

Each jail backed by ZFS dataset at /data/
```

### Network Model

- **inherit**: Jails share host network stack (simple, efficient)
- **Ports**: 80/443 (Nginx), 5432 (PostgreSQL), 3000 (Rails), 5000 (Next.js)
- **Internal communication**: Direct via localhost/network

### Storage Model

- **ZFS Datasets**: `zroot/{service-name}` → `/data/{service-name}` → `/var/db` or `/var/app`, `/var/web` inside jails
- **Persistent**: Application code and data survive jail restarts

## 🏗️ Deployment Architecture: Pot Flavours

**Flavours** provide declarative jail configurations:

```mermaid
architecture-beta
    group flavours(disk)[Pot Flavours]
        service db(database)[portfolio-databases] in flavours
        service api(server)[portfolio-api] in flavours
        service web(server)[portfolio-web] in flavours
        service proxy(internet)[portfolio-reverse-proxy] in flavours

    group setup(cloud)[Setup Phase]
        service setup_script(server)[setup-jails-flavours.sh] in setup

    group deploy(cloud)[Deploy Phase]
        service deploy_script(server)[deploy-flavours.sh] in deploy

    group nomad(cloud)[Nomad Orchestration]
        service nomad_jobs(server)[*.hcl jobs] in nomad

    flavours:R --> L:setup
    setup:R --> L:deploy
    deploy:R --> L:nomad
```

### Flavour Files (in `pot/flavours/`)

Each service has **3 files**:

1. **Configuration** (no extension) - Pot commands: `set-attribute`, `set-env`, `set-rss`
2. **Bootstrap** (`.sh`) - Shell script executed during jail creation
3. **Startup Command** (`-cmd`) - Sets the main process command

## 📁 File Structure

```
nomad/
├── pot/
│   ├── flavours/                          ← Service definitions
│   ├── setup-jails-flavours.sh            ← Infrastructure creation
│   ├── deploy-flavours.sh                 ← Code deployment
│   ├── install-flavours.sh                ← Flavour installation
│   └── health-checks/                     ← Monitoring
├── jobs/
│   ├── postgres.hcl
│   ├── api.hcl
│   ├── web.hcl
│   └── nginx.hcl
├── SETUP.md                               ← Architecture overview (this file)
├── FLAVOURS.md                            ← Flavour architecture details
└── QUICKSTART.md                          ← Step-by-step deployment
```

## ✅ Prerequisites

- **FreeBSD 14.3+**
- **Pot 0.15.0+**: `pkg install pot`
- **Nomad 1.9.6+**: `pkg install nomad`
- **ZFS pool**: Verify with `zfs list`
- **SSH access**: For remote flavour installation
- **Sudo/root**: For jail and network operations

## 🚀 Deployment Overview

### Phase 1: Prepare Flavours
```bash
# From Linux machine
./nomad/pot/install-flavours.sh root@freebsd-server
```

### Phase 2: Create Infrastructure
```bash
# On FreeBSD server
sudo ./nomad/pot/setup-jails-flavours.sh
```

### Phase 3: Deploy Code
```bash
# On FreeBSD server
sudo ./nomad/pot/deploy-flavours.sh
```

### Phase 4: Orchestrate with Nomad
```bash
nomad job run nomad/jobs/*.hcl
nomad job status
```

**→ For detailed steps, see [QUICKSTART.md](QUICKSTART.md)**

## 🏗️ Why Pot Flavours?

✅ **Declarative** - Configurations defined once, reused everywhere
✅ **Version-controlled** - Flavours live in Git
✅ **Reproducible** - Identical setup, every deployment
✅ **Native Design** - Works with Pot's intended approach
✅ **No Workarounds** - No imperative hacks or timing issues

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **QUICKSTART.md** | Step-by-step deployment guide |
| **FLAVOURS.md** | Architecture & design details |
| **This file** | System overview & concepts |

## 🔐 Security Considerations

- Jails use `inherit` network (not isolated from host)
- PostgreSQL configured for external network access (configure firewalls)
- Nomad raw_exec driver runs as privileged
- Configure SSL/TLS in Nginx for external access
- Use firewall rules to restrict network access

## 🔧 Configuration

Environment variables configured in flavour files:
- `RAILS_ENV=production`
- `NODE_ENV=production`
- `POSTGRES_INITDB_ARGS="-c max_connections=200"`

See individual flavour files for full configuration.

## 📖 Next Steps

1. **Deploy**: Read [QUICKSTART.md](QUICKSTART.md)
2. **Understand**: Read [FLAVOURS.md](FLAVOURS.md) for detailed architecture
3. **Configure**: Update Nomad config in `nomad-config-example.hcl`
4. **Execute**: Follow the four-phase deployment process

---

**Distinguished Engineering.** Pot flavours are the proper, sustainable way to manage FreeBSD jails—not workarounds, just proper design.
