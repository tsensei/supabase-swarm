# Supabase Self-Hosting with Docker 🚀

<div align="center">
  <img src="assets/cover.png" alt="Supabase Docker Swarm Cover" width="800">
</div>

A production-ready Supabase self-hosting configuration that works with Docker Compose, Docker Swarm, and Portainer.

## ⭐ Love this project?

If this configuration helped you get Supabase running smoothly, please consider giving it a star! It really helps others discover this solution.

## 🚀 Quick Start

### Prerequisites

- Docker Engine
- Domain name (optional, for production)
- S3-compatible storage credentials (required for file storage)

### Choose Your Deployment Method

| Method | Best For | Setup |
|--------|----------|-------|
| **Docker Compose** | Development, single server | [📖 Wiki Guide](wiki/docker-compose.md) |
| **Docker Swarm** | Production, multi-server | [📖 Wiki Guide](wiki/docker-swarm.md) |
| **Portainer** | GUI management | [📖 Wiki Guide](wiki/portainer.md) |

### Quick Commands

```bash
# Clone and setup
git clone <your-repo-url>
cd supabase-swarm

# Choose your method and follow the wiki guide
# Or run automated setup
./setup.sh --help
```

## 📚 Documentation

- **[Wiki Home](wiki/README.md)** - Complete documentation
- **[Deployment Methods](wiki/deployment-methods.md)** - Compare all options
- **[Troubleshooting](wiki/troubleshooting.md)** - Common issues and solutions
- **[Configuration](wiki/configuration.md)** - Environment variables and settings

## 🌐 Access Supabase

- **Studio**: http://localhost:8000
- **API**: http://localhost:8000/rest/v1/
- **Auth**: http://localhost:8000/auth/v1/

Default credentials: `supabase` / `this_password_is_insecure_and_should_be_updated`

## 🔧 Files

- `docker-compose.yml` - Docker Swarm/Portainer configuration
- `docker-compose.standalone.yml` - Docker Compose configuration
- `setup.sh` - Automated setup script
- `environment-variables.txt` - Configuration template

## 🤝 Contributing

Found a bug? Have an improvement? Please contribute back to help others!

- 🐛 Found a bug? Open an issue!
- 💡 Have an improvement? Submit a PR!
- 📚 Documentation needs work? We'd love your help!
- ⭐ Star the repo if it helped you!

## 📄 License

Apache 2.0 License (same as Supabase)

---

> 🎯 **Goal**: Make Supabase self-hosting as painless as possible for everyone!