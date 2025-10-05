# Troubleshooting Guide 🔧

This guide covers common issues and solutions when deploying Supabase with Docker.

## 🚨 Common Issues

### Services Not Starting

#### Problem: "External volume/network/config not found"

**Symptoms**:
- Services fail to start
- Error messages about missing external resources
- Stack deployment fails

**Solutions**:

**For Docker Compose users**:
```bash
# Use the standalone compose file instead
docker-compose -f docker-compose.standalone.yml up -d
```

**For Docker Swarm users**:
```bash
# Run the setup script to create external resources
./setup.sh --swarm
```

**For Portainer users**:
1. Go to Volumes → Add volume (create all required volumes)
2. Go to Networks → Add network (create `supabase_overlay`)
3. Go to Configs → Add config (create all required configs)

#### Problem: "Config files not found"

**Symptoms**:
- Services fail to start
- Error messages about missing config files
- Kong or database initialization fails

**Solutions**:

**For Docker Compose users**:
```bash
# Run the setup script to create the override file
./setup.sh --compose
```

**For Docker Swarm users**:
```bash
# Run the setup script to create external configs
./setup.sh --swarm
```

**For Portainer users**:
1. Go to Configs → Add config
2. Create configs from files in `volumes/` directory
3. Ensure all required configs exist

#### Problem: "Permission denied"

**Symptoms**:
- Services fail to start
- Permission errors in logs
- Volume mount failures

**Solutions**:
```bash
# Fix volume permissions
sudo chown -R $USER:$USER volumes/
chmod -R 755 volumes/

# Check Docker socket permissions
sudo chmod 666 /var/run/docker.sock
```

### Database Issues

#### Problem: "Database connection failed"

**Symptoms**:
- Database service not starting
- Connection timeout errors
- Authentication failures

**Solutions**:

1. **Check Database Password**:
   ```bash
   # Verify POSTGRES_PASSWORD is set correctly
   echo $POSTGRES_PASSWORD
   
   # Generate new password if needed
   openssl rand -base64 32
   ```

2. **Check Database Service**:
   ```bash
   # Docker Compose
   docker-compose -f docker-compose.standalone.yml ps db
   
   # Docker Swarm
   docker service ps supabase_db
   ```

3. **Check Database Logs**:
   ```bash
   # Docker Compose
   docker-compose -f docker-compose.standalone.yml logs db
   
   # Docker Swarm
   docker service logs supabase_db
   ```

#### Problem: "Database initialization failed"

**Symptoms**:
- Database service starts but fails initialization
- SQL script errors
- Schema creation failures

**Solutions**:

1. **Check SQL Files**:
   ```bash
   # Verify SQL files exist
   ls -la volumes/db/
   
   # Check file permissions
   chmod 644 volumes/db/*.sql
   ```

2. **Check Database Logs**:
   ```bash
   # Look for SQL errors
   docker-compose -f docker-compose.standalone.yml logs db | grep -i error
   ```

3. **Recreate Database**:
   ```bash
   # Stop and remove database volume
   docker-compose -f docker-compose.standalone.yml down
   docker volume rm supabase-production-db-data
   
   # Restart
   docker-compose -f docker-compose.standalone.yml up -d
   ```

### API Key Issues

#### Problem: "Invalid API key" or "JWT verification failed"

**Symptoms**:
- API requests fail with 401 errors
- Studio shows authentication errors
- Service-to-service communication fails

**Solutions**:

1. **Regenerate API Keys**:
   - Visit [Supabase API Key Generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
   - Use your 40-character JWT secret
   - Generate both `ANON_KEY` and `SERVICE_ROLE_KEY`

2. **Check JWT Secret**:
   ```bash
   # Verify JWT_SECRET is exactly 40 characters
   echo $JWT_SECRET | wc -c
   
   # Generate new JWT secret if needed
   openssl rand -hex 20
   ```

3. **Update Environment Variables**:
   ```bash
   # Edit .env file
   nano .env
   
   # Restart services
   docker-compose -f docker-compose.standalone.yml restart
   ```

### Studio Issues

#### Problem: "Studio not loading" or "Connection refused"

**Symptoms**:
- Studio web interface not accessible
- Connection timeout errors
- Blank page or loading errors

**Solutions**:

1. **Check Studio Service**:
   ```bash
   # Docker Compose
   docker-compose -f docker-compose.standalone.yml ps studio
   
   # Docker Swarm
   docker service ps supabase_studio
   ```

2. **Check Studio Logs**:
   ```bash
   # Docker Compose
   docker-compose -f docker-compose.standalone.yml logs studio
   
   # Docker Swarm
   docker service logs supabase_studio
   ```

3. **Check Kong Service**:
   ```bash
   # Kong routes traffic to Studio
   docker-compose -f docker-compose.standalone.yml logs kong
   ```

4. **Check Port Availability**:
   ```bash
   # Check if port 8000 is available
   netstat -tulpn | grep :8000
   
   # Check if port is blocked by firewall
   sudo ufw status
   ```

### Storage Issues

#### Problem: "Storage service not working"

**Symptoms**:
- File uploads fail
- Storage API returns errors
- S3 connection failures

**Solutions**:

1. **Check S3 Configuration**:
   ```bash
   # Verify AWS credentials
   echo $AWS_ACCESS_KEY_ID
   echo $AWS_SECRET_ACCESS_KEY
   echo $AWS_DEFAULT_REGION
   ```

2. **Check Storage Service**:
   ```bash
   # Docker Compose
   docker-compose -f docker-compose.standalone.yml logs storage
   
   # Docker Swarm
   docker service logs supabase_storage
   ```

3. **Test S3 Connection**:
   ```bash
   # Test AWS CLI access
   aws s3 ls
   ```

### Network Issues

#### Problem: "Service discovery failed" or "Network connectivity issues"

**Symptoms**:
- Services can't communicate with each other
- Connection timeout errors
- DNS resolution failures

**Solutions**:

1. **Check Network**:
   ```bash
   # Check if network exists
   docker network ls | grep supabase_overlay
   
   # Create network if missing
   docker network create supabase_overlay
   ```

2. **Check Service Connectivity**:
   ```bash
   # Test connectivity between services
   docker exec -it $(docker ps -q -f name=supabase_studio) ping kong
   ```

3. **Check DNS Resolution**:
   ```bash
   # Test DNS resolution
   docker exec -it $(docker ps -q -f name=supabase_studio) nslookup kong
   ```

## 🔍 Debug Commands

### Docker Compose

```bash
# Check service status
docker-compose -f docker-compose.standalone.yml ps

# View logs
docker-compose -f docker-compose.standalone.yml logs

# Check specific service logs
docker-compose -f docker-compose.standalone.yml logs studio

# Follow logs in real-time
docker-compose -f docker-compose.standalone.yml logs -f studio

# Restart services
docker-compose -f docker-compose.standalone.yml restart

# Stop and cleanup
docker-compose -f docker-compose.standalone.yml down

# Stop and remove volumes
docker-compose -f docker-compose.standalone.yml down -v
```

### Docker Swarm

```bash
# Check stack status
docker stack services supabase

# Check specific service
docker service inspect supabase_studio

# View service logs
docker service logs supabase_studio

# Follow logs
docker service logs -f supabase_studio

# Scale service
docker service scale supabase_studio=2

# Update service
docker service update supabase_studio
```

### Portainer

1. **Check Stack Status**: Go to Stacks → supabase
2. **View Service Logs**: Click on service → Logs tab
3. **Check Resource Usage**: Go to Stacks → supabase → Services
4. **View Events**: Go to Stacks → supabase → Events
5. **Check External Resources**: Go to Volumes, Networks, Configs

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

### Log Analysis

```bash
# Check for errors
docker-compose -f docker-compose.standalone.yml logs | grep -i error

# Check for warnings
docker-compose -f docker-compose.standalone.yml logs | grep -i warning

# Check for specific patterns
docker-compose -f docker-compose.standalone.yml logs | grep -i "connection"
```

## 🆘 Getting Help

### Before Asking for Help

1. **Check this guide** for common solutions
2. **Check service logs** for error messages
3. **Verify configuration** in `.env` file
4. **Test with minimal configuration** first

### When Asking for Help

1. **Include error messages** from logs
2. **Include your configuration** (sanitized)
3. **Include deployment method** (Compose/Swarm/Portainer)
4. **Include system information** (OS, Docker version)

### Useful Information to Include

```bash
# System information
uname -a
docker --version
docker-compose --version

# Service status
docker-compose -f docker-compose.standalone.yml ps

# Recent logs
docker-compose -f docker-compose.standalone.yml logs --tail 50

# Configuration (sanitized)
grep -v "PASSWORD\|SECRET\|KEY" .env
```

---

**Still having issues?** Open an issue on GitHub with the information above.
