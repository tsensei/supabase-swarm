# Docker Compose Deployment Guide 🐳

This guide covers deploying Supabase using Docker Compose - perfect for development, testing, and single-server deployments.

## 🎯 When to Use Docker Compose

- ✅ Development and testing
- ✅ Single server deployment
- ✅ Learning Docker and Supabase
- ✅ Quick setup and iteration
- ✅ Local development environment

## 📋 Prerequisites

- Docker Engine installed
- Docker Compose installed
- Basic command line knowledge
- 4GB+ RAM available
- 10GB+ disk space

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd supabase-swarm

# Copy environment template
cp environment-variables.txt .env

# Edit environment variables
nano .env
```

### 2. Generate Required Secrets

```bash
# Generate JWT Secret (40 characters)
openssl rand -hex 20

# Generate Database Password
openssl rand -base64 32

# Generate Kong Dashboard Password
openssl rand -base64 16
```

### 3. Generate API Keys

1. Visit [Supabase API Key Generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
2. Use your 40-character JWT secret
3. Generate `ANON_KEY` (run form with "anon" role)
4. Generate `SERVICE_ROLE_KEY` (run form with "service" role)
5. Update your `.env` file with these keys

### 4. Deploy Supabase

```bash
# Deploy with standalone compose file
docker-compose -f docker-compose.standalone.yml up -d

# Check deployment status
docker-compose -f docker-compose.standalone.yml ps

# View logs
docker-compose -f docker-compose.standalone.yml logs -f studio
```

## 🔧 Configuration

### Required Environment Variables

Edit your `.env` file with these essential variables:

```bash
# Database Configuration
POSTGRES_HOST=db
POSTGRES_PORT=5432
POSTGRES_DB=postgres
POSTGRES_PASSWORD=your-generated-password

# JWT Configuration
JWT_SECRET=your-40-character-jwt-secret
JWT_EXPIRY=3600

# API Keys (generate from Supabase website)
ANON_KEY=your-anon-key
SERVICE_ROLE_KEY=your-service-role-key

# URLs
API_EXTERNAL_URL=http://localhost:8000
SITE_URL=http://localhost:3000
SUPABASE_PUBLIC_URL=http://localhost:8000
```

### Optional Configuration

```bash
# Studio Settings
STUDIO_DEFAULT_ORGANIZATION=My Organization
STUDIO_DEFAULT_PROJECT=My Project

# Authentication Settings
DISABLE_SIGNUP=false
ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false

# SMTP Configuration (for email notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

## 🌐 Accessing Services

### Supabase Studio
- **URL**: http://localhost:8000
- **Username**: `supabase`
- **Password**: `this_password_is_insecure_and_should_be_updated`

### API Endpoints
- **REST API**: http://localhost:8000/rest/v1/
- **Auth API**: http://localhost:8000/auth/v1/
- **Storage API**: http://localhost:8000/storage/v1/
- **Realtime**: http://localhost:8000/realtime/v1/
- **Edge Functions**: http://localhost:8000/functions/v1/

## 🔍 Management Commands

### View Status
```bash
# Check all services
docker-compose -f docker-compose.standalone.yml ps

# Check specific service
docker-compose -f docker-compose.standalone.yml ps studio
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.standalone.yml logs

# Specific service
docker-compose -f docker-compose.standalone.yml logs studio

# Follow logs in real-time
docker-compose -f docker-compose.standalone.yml logs -f studio
```

### Restart Services
```bash
# Restart all services
docker-compose -f docker-compose.standalone.yml restart

# Restart specific service
docker-compose -f docker-compose.standalone.yml restart studio
```

### Stop and Cleanup
```bash
# Stop services
docker-compose -f docker-compose.standalone.yml down

# Stop and remove volumes (⚠️ Data loss!)
docker-compose -f docker-compose.standalone.yml down -v
```

## 🔧 Troubleshooting

### Services Won't Start
1. Check if ports are available: `netstat -tulpn | grep :8000`
2. Verify environment variables in `.env`
3. Check Docker logs: `docker-compose -f docker-compose.standalone.yml logs`

### Database Connection Issues
1. Verify `POSTGRES_PASSWORD` is set correctly
2. Check if database container is running: `docker-compose -f docker-compose.standalone.yml ps db`
3. Check database logs: `docker-compose -f docker-compose.standalone.yml logs db`

### API Key Errors
1. Regenerate API keys using the official generator
2. Ensure JWT_SECRET is exactly 40 characters
3. Verify keys are correctly set in `.env`

### Studio Not Loading
1. Check if Kong is running: `docker-compose -f docker-compose.standalone.yml ps kong`
2. Verify `SUPABASE_PUBLIC_URL` is set correctly
3. Check Kong logs: `docker-compose -f docker-compose.standalone.yml logs kong`

## 📊 Monitoring

### Health Checks
```bash
# Check service health
docker-compose -f docker-compose.standalone.yml ps

# Check specific service health
docker inspect $(docker-compose -f docker-compose.standalone.yml ps -q studio) | grep Health
```

### Resource Usage
```bash
# Check resource usage
docker stats

# Check specific service resources
docker stats $(docker-compose -f docker-compose.standalone.yml ps -q)
```

## 🔄 Updates

### Update Supabase Images
```bash
# Pull latest images
docker-compose -f docker-compose.standalone.yml pull

# Restart with new images
docker-compose -f docker-compose.standalone.yml up -d
```

### Update Configuration
1. Edit `.env` file
2. Restart affected services: `docker-compose -f docker-compose.standalone.yml restart`

## 🗂️ File Structure

```
supabase/
├── docker-compose.standalone.yml  # Main compose file
├── environment-variables.txt      # Template
├── .env                          # Your configuration
└── volumes/                      # Config files
    ├── api/kong.yml
    ├── db/*.sql
    ├── functions/main/index.ts
    └── logs/vector.yml
```

## 💡 Tips

1. **Start Simple**: Use default configuration first, then customize
2. **Monitor Logs**: Check logs regularly for issues
3. **Backup Data**: Regular backups of volumes
4. **Resource Limits**: Set appropriate resource limits for production
5. **Security**: Change default passwords immediately

## 🚀 Next Steps

- [Configuration Guide](configuration.md) - Detailed configuration options
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
- [Docker Swarm Guide](docker-swarm.md) - Production deployment
- [Portainer Guide](portainer.md) - GUI management

---

**Need Help?** Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
