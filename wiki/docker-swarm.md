# Docker Swarm Deployment Guide 🐝

This guide covers deploying Supabase using Docker Swarm - perfect for production deployments with high availability and scaling.

## 🎯 When to Use Docker Swarm

- ✅ Production deployments
- ✅ Multi-server environments
- ✅ High availability required
- ✅ Automatic load balancing
- ✅ Rolling updates
- ✅ Service scaling

## 📋 Prerequisites

- Docker Engine installed on all nodes
- Docker Swarm initialized
- Network connectivity between nodes
- 8GB+ RAM per node
- 20GB+ disk space per node
- Domain name (optional, for production)

## 🚀 Quick Start

### 1. Initialize Docker Swarm

```bash
# On manager node
docker swarm init

# On worker nodes
docker swarm join --token <token> <manager-ip>:2377
```

### 2. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd supabase-swarm

# Run automated setup script
./setup.sh --swarm

# Copy environment template
cp environment-variables.txt .env

# Edit environment variables
nano .env
```

### 3. Generate Required Secrets

```bash
# Generate JWT Secret (40 characters)
openssl rand -hex 20

# Generate Database Password
openssl rand -base64 32

# Generate Kong Dashboard Password
openssl rand -base64 16
```

### 4. Generate API Keys

1. Visit [Supabase API Key Generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
2. Use your 40-character JWT secret
3. Generate `ANON_KEY` (run form with "anon" role)
4. Generate `SERVICE_ROLE_KEY` (run form with "service" role)
5. Update your `.env` file with these keys

### 5. Deploy Supabase Stack

```bash
# Deploy using the automated script (recommended)
./deploy-swarm.sh

# OR deploy manually (requires environment variables to be exported)
docker stack deploy -c docker-compose.yml supabase

# Check deployment status
docker stack services supabase

# View logs
docker service logs supabase_db
```

### About the Deployment Script

The `deploy-swarm.sh` script provides several benefits:

- ✅ **Automatic Environment Loading**: Loads variables from `.env` file
- ✅ **Validation**: Checks that required variables are set
- ✅ **Error Handling**: Provides clear error messages
- ✅ **Swarm Compatibility**: Works properly with Docker Swarm
- ✅ **User-Friendly**: Clear status messages and next steps

**Manual Deployment**: If you prefer manual deployment, ensure environment variables are exported:

```bash
# Export all variables from .env file
set -a && source .env && set +a

# Deploy the stack
docker stack deploy -c docker-compose.yml supabase
```

**Important**: Ensure your `.env` file is properly formatted:
- Values with spaces must be quoted: `VAR="value with spaces"`
- No spaces around `=` sign: `VAR=value` (not `VAR = value`)
- No special characters without quotes

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
API_EXTERNAL_URL=http://your-domain.com:8000
SITE_URL=http://your-domain.com:3000
SUPABASE_PUBLIC_URL=http://your-domain.com:8000
```

### Production Configuration

```bash
# Security Settings
DISABLE_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=true

# SMTP Configuration
SMTP_HOST=smtp.your-provider.com
SMTP_PORT=587
SMTP_USER=noreply@yourdomain.com
SMTP_PASS=your-smtp-password

# Storage Configuration
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-east-1
```

## 🌐 Accessing Services

### Supabase Studio
- **URL**: http://your-domain.com:8000
- **Username**: `supabase`
- **Password**: `this_password_is_insecure_and_should_be_updated`

### API Endpoints
- **REST API**: http://your-domain.com:8000/rest/v1/
- **Auth API**: http://your-domain.com:8000/auth/v1/
- **Storage API**: http://your-domain.com:8000/storage/v1/
- **Realtime**: http://your-domain.com:8000/realtime/v1/
- **Edge Functions**: http://your-domain.com:8000/functions/v1/

## 🔍 Management Commands

### Stack Management
```bash
# Check stack status
docker stack services supabase

# Check specific service
docker service inspect supabase_studio

# Scale service
docker service scale supabase_studio=2

# Update service
docker service update supabase_studio
```

### Logs and Monitoring
```bash
# View service logs
docker service logs supabase_studio

# Follow logs
docker service logs -f supabase_studio

# Check service health
docker service ps supabase_studio
```

### Node Management
```bash
# List nodes
docker node ls

# Inspect node
docker node inspect <node-id>

# Add labels to node
docker node update --label-add server=production <node-id>

# Remove node
docker node rm <node-id>
```

## 🔧 Troubleshooting

### Environment Variable Issues

**Problem**: Services fail with "POSTGRES_PASSWORD not specified" or similar environment variable errors.

**Solution**: Docker Swarm doesn't support the `env_file` directive. Use the provided deployment script:

```bash
# Use the automated deployment script
./deploy-swarm.sh

# OR manually export variables before deployment
set -a && source .env && set +a
docker stack deploy -c docker-compose.yml supabase
```

**Why**: Docker Swarm requires environment variables to be exported to the shell environment, unlike Docker Compose which supports `env_file`.

### Services Not Starting
1. Check if external resources exist: `docker volume ls`, `docker network ls`, `docker config ls`
2. Verify environment variables in `.env`
3. Check service logs: `docker service logs supabase_studio`

### Database Connection Issues
1. Verify `POSTGRES_PASSWORD` is set correctly
2. Check if database service is running: `docker service ps supabase_db`
3. Check database logs: `docker service logs supabase_db`

### Load Balancing Issues
1. Check if Kong service is running: `docker service ps supabase_kong`
2. Verify network connectivity: `docker network inspect supabase_overlay`
3. Check Kong logs: `docker service logs supabase_kong`

### Scaling Issues
1. Check node resources: `docker node inspect <node-id>`
2. Verify placement constraints in compose file
3. Check service replicas: `docker service ps supabase_studio`

## 📊 Monitoring

### Health Checks
```bash
# Check all services
docker stack services supabase

# Check service health
docker service ps supabase_studio --no-trunc
```

### Resource Usage
```bash
# Check node resources
docker node inspect <node-id> | grep -A 10 Resources

# Check service resource usage
docker service inspect supabase_studio | grep -A 10 Resources
```

### Logs Analysis
```bash
# Check logs for errors
docker service logs supabase_studio | grep -i error

# Check logs for warnings
docker service logs supabase_studio | grep -i warning
```

## 🔄 Updates

### Rolling Updates
```bash
# Update service image
docker service update --image supabase/studio:latest supabase_studio

# Update with specific parameters
docker service update --update-parallelism 1 --update-delay 30s supabase_studio
```

### Stack Updates
```bash
# Update entire stack
docker stack deploy -c docker-compose.yml supabase

# Check update progress
docker stack services supabase
```

## 🏗️ Production Considerations

### Security
- [ ] Change default passwords
- [ ] Enable HTTPS with SSL certificates
- [ ] Configure firewall rules
- [ ] Set up monitoring and alerting
- [ ] Regular security updates

### High Availability
- [ ] Deploy across multiple nodes
- [ ] Configure health checks
- [ ] Set up automatic failover
- [ ] Monitor service health
- [ ] Regular backups

### Performance
- [ ] Configure resource limits
- [ ] Optimize database settings
- [ ] Set up caching
- [ ] Monitor performance metrics
- [ ] Load testing

## 🗂️ File Structure

```
supabase/
├── docker-compose.yml          # Swarm compose file
├── environment-variables.txt    # Template
├── .env                        # Your configuration
├── setup.sh                    # Setup script
└── volumes/                    # Config files
    ├── api/kong.yml
    ├── db/*.sql
    ├── functions/main/index.ts
    └── logs/vector.yml
```

## 💡 Tips

1. **Start Small**: Begin with single node, then scale
2. **Monitor Resources**: Watch CPU, memory, and disk usage
3. **Regular Backups**: Automated backup strategy
4. **Security First**: Change defaults, enable HTTPS
5. **Test Failover**: Verify high availability works

## 🚀 Next Steps

- [Configuration Guide](configuration.md) - Detailed configuration options
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
- [Monitoring Guide](monitoring.md) - Health checks and logging
- [Backup Guide](backup.md) - Data backup strategies

---

**Need Help?** Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
