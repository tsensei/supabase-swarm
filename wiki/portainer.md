# Portainer Deployment Guide 🖥️

This guide covers deploying Supabase using Portainer - perfect for GUI-based management and team collaboration.

## 🎯 When to Use Portainer

- ✅ GUI-based management preferred
- ✅ Team collaboration needed
- ✅ Visual monitoring and logs
- ✅ User-friendly interface
- ✅ Managing multiple projects
- ✅ Non-technical team members

## 📋 Prerequisites

- Portainer installed and running
- Docker Swarm initialized (if using Swarm mode)
- Access to Portainer web interface
- Basic understanding of Docker concepts
- 8GB+ RAM available
- 20GB+ disk space

## 🚀 Quick Start

### 1. Install Portainer

```bash
# Install Portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
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

### 5. Create External Resources in Portainer

#### Option A: Using Portainer GUI

1. **Create Network**:
   - Go to Networks → Add network
   - Name: `supabase_overlay`
   - Driver: `overlay` (for Swarm) or `bridge` (for standalone)
   - Create network

2. **Create Volumes**:
   - Go to Volumes → Add volume
   - Create these volumes:
     - `supabase-production-storage-data`
     - `supabase-production-functions-data`
     - `supabase-production-db-data`
     - `supabase-production-db-config`

3. **Create Configs** (Swarm mode only):
   - Go to Configs → Add config
   - Create configs from files in `volumes/` directory:
     - `99-logs.sql` from `volumes/db/logs.sql`
     - `99-realtime.sql` from `volumes/db/realtime.sql`
     - `99-roles.sql` from `volumes/db/roles.sql`
     - `98-webhooks.sql` from `volumes/db/webhooks.sql`
     - `99-jwt.sql` from `volumes/db/jwt.sql`
     - `97-_supabase.sql` from `volumes/db/_supabase.sql`
     - `99-pooler.sql` from `volumes/db/pooler.sql`
     - `vector.yml` from `volumes/logs/vector.yml`
     - `kong.yml` from `volumes/api/kong.yml`
     - `main.ts` from `volumes/functions/main/index.ts`

#### Option B: Using Setup Script

```bash
# Run the automated setup script
./setup.sh --swarm

# This creates all external resources automatically
```

### 6. Deploy Stack in Portainer

1. **Go to Stacks** in Portainer
2. **Click "Add stack"**
3. **Name**: `supabase`
4. **Build method**: Choose "Upload" or "Repository"
5. **Upload docker-compose.yml** or paste the content
6. **Environment variables**: 
   - Click "Add environment variable" for each variable in your `.env` file
   - Or upload the `.env` file if Portainer supports it
7. **Deploy the stack**

## 🔧 Configuration

### Required Environment Variables

Add these environment variables in Portainer:

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

### Adding Environment Variables in Portainer

1. Go to Stacks → supabase
2. Click "Editor" tab
3. Scroll down to "Environment variables"
4. Click "Add environment variable"
5. Add each variable from your `.env` file

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

## 🔍 Management in Portainer

### Stack Management
- **View Stack**: Go to Stacks → supabase
- **Edit Stack**: Click "Editor" tab
- **Update Stack**: Click "Update the stack"
- **Delete Stack**: Click "Delete the stack"

### Service Management
- **View Services**: Go to Stacks → supabase → Services
- **View Logs**: Click on service → Logs tab
- **Scale Service**: Click on service → Scale
- **Restart Service**: Click on service → Restart

### Monitoring
- **Resource Usage**: Go to Stacks → supabase → Services
- **Health Status**: Check service status indicators
- **Logs**: Click on service → Logs tab
- **Events**: Go to Stacks → supabase → Events

## 🔧 Troubleshooting

### Stack Deployment Fails
1. **Check External Resources**: Verify all volumes, networks, and configs exist
2. **Check Environment Variables**: Ensure all required variables are set
3. **Check Logs**: Go to Stacks → supabase → Events for error messages
4. **Check Portainer Logs**: Go to Settings → About → View logs

### Services Not Starting
1. **Check Service Logs**: Click on service → Logs tab
2. **Check Resource Usage**: Ensure sufficient resources available
3. **Check Dependencies**: Verify dependent services are running
4. **Check Configuration**: Verify environment variables are correct

### External Resources Not Found
1. **Check Volumes**: Go to Volumes → verify all required volumes exist
2. **Check Networks**: Go to Networks → verify `supabase_overlay` exists
3. **Check Configs**: Go to Configs → verify all required configs exist
4. **Recreate Resources**: Use setup script or recreate manually

### Environment Variables Not Working
1. **Check Variable Names**: Ensure exact spelling and case
2. **Check Values**: Verify values are correct and not empty
3. **Check Special Characters**: Escape special characters properly
4. **Restart Stack**: Update stack to apply new variables

## 📊 Monitoring

### Health Checks
- **Service Status**: Check service status indicators in Portainer
- **Health Checks**: View health check results in service details
- **Resource Usage**: Monitor CPU, memory, and disk usage

### Logs
- **Service Logs**: Click on service → Logs tab
- **Stack Logs**: Go to Stacks → supabase → Events
- **Portainer Logs**: Go to Settings → About → View logs

### Alerts
- **Service Alerts**: Configure alerts for service failures
- **Resource Alerts**: Set up alerts for resource usage
- **Health Alerts**: Configure health check failure alerts

## 🔄 Updates

### Updating Stack
1. **Edit Stack**: Go to Stacks → supabase → Editor
2. **Update Configuration**: Modify compose file or environment variables
3. **Update Stack**: Click "Update the stack"
4. **Monitor Update**: Watch update progress in Events tab

### Updating Services
1. **Select Service**: Go to Stacks → supabase → Services
2. **Update Service**: Click on service → Update
3. **Configure Update**: Set update parameters
4. **Apply Update**: Click "Update the service"

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

1. **Start Simple**: Use default configuration first, then customize
2. **Monitor Resources**: Watch CPU, memory, and disk usage
3. **Regular Backups**: Automated backup strategy
4. **Security First**: Change defaults, enable HTTPS
5. **Team Collaboration**: Use Portainer's user management features

## 🚀 Next Steps

- [Configuration Guide](configuration.md) - Detailed configuration options
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
- [Monitoring Guide](monitoring.md) - Health checks and logging
- [Backup Guide](backup.md) - Data backup strategies

---

**Need Help?** Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
