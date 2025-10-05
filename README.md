# Supabase Self-Hosting with Docker Swarm 🚀

A production-ready Supabase self-hosting configuration optimized for Docker Swarm deployment. This setup has been battle-tested in production for over a year and addresses the common issues found in the official Supabase Docker guides.

## ⭐ Love this project?

If this configuration helped you get Supabase running smoothly with Docker Swarm, please consider giving it a star! It really helps others discover this solution and motivates continued development.

## 💡 Why This Exists

The official Supabase Docker guides are not regularly updated and making them work with Docker Swarm was... well, let's just say it wasn't fun! 😅 This configuration is the result of multiple days of iterations, debugging, and learning from production deployments to create a stable, reliable setup that actually works.

## 🚀 Quick Start

### Prerequisites

- Docker Swarm cluster
- Domain name (optional, for production)

### Node Labeling (Optional)

By default, services will run on any available node. If you want to restrict services to specific nodes, you can:

1. **Label your nodes**:
   ```bash
   # Label a node for production workloads
   docker node update --label-add server=production <node-id>
   
   # Check node labels
   docker node inspect <node-id> | grep -A 10 Labels
   ```

2. **Enable placement constraints** in docker-compose.yml:
   - Uncomment the `placement` sections in each service
   - Services will only run on nodes with `server=production` label

3. **Update labels**:
   ```bash
   # Add additional labels
   docker node update --label-add environment=prod <node-id>
   docker node update --label-add region=us-east <node-id>
   
   # Remove labels
   docker node update --label-rm server <node-id>
   ```

### 1. Clone and Setup

```bash
# Clone this repository
git clone <your-repo-url>
cd supabase-swarm

# Copy the environment template
cp environment-variables.txt .env

# Edit the environment file with your values
nano .env
```

### 2. Generate Secrets

```bash
# Generate JWT Secret (40 characters for Supabase API key generator)
openssl rand -hex 20

# Generate Database Password
openssl rand -base64 32

# Generate Kong Dashboard Password
openssl rand -base64 16
```

### 3. Generate API Keys

1. Visit the [Supabase API Key Generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
2. Use your 40-character JWT secret
3. Generate both `ANON_KEY` and `SERVICE_ROLE_KEY` (run the form twice)
4. Update your `.env` file with these keys

### 4. Deploy to Swarm

```bash
# Deploy the stack
docker stack deploy -c docker-compose.yml supabase

# Check deployment status
docker stack services supabase

# View logs
docker service logs supabase_studio
```

## 📋 Configuration

### Environment Variables

All environment variables are documented in `environment-variables.txt`. Key sections include:

- **Core Supabase Configuration**: Database, JWT, API keys
- **Authentication Settings**: Signup, email, phone, MFA
- **Email Configuration**: SMTP settings for notifications
- **Storage Configuration**: S3-compatible storage
- **Analytics & Logging**: Logflare configuration

## 🌐 Accessing Services

### Supabase Studio
- **URL**: `http://your-server:8000`
- **Default Credentials**: 
  - Username: `supabase`
  - Password: `this_password_is_insecure_and_should_be_updated`
- **⚠️ Change these immediately in production!**

### API Endpoints
- **REST API**: `http://your-server:8000/rest/v1/`
- **Auth API**: `http://your-server:8000/auth/v1/`
- **Storage API**: `http://your-server:8000/storage/v1/`
- **Realtime**: `http://your-server:8000/realtime/v1/`
- **Edge Functions**: `http://your-server:8000/functions/v1/`

## 🔧 Production Considerations

### Security Checklist

Before going live, make sure to:

- [ ] Change default passwords (seriously, do this! 🔒)
- [ ] Generate new JWT secrets
- [ ] Configure SMTP for email notifications
- [ ] Set up S3 storage backend

## 🔧 Traefik Configuration (Optional)

The docker-compose.yml file includes commented-out Traefik labels for automatic SSL termination and routing. These are preserved for easy re-enabling when needed.

### Included Traefik Features

- **Automatic SSL/TLS termination** with Let's Encrypt
- **HTTP to HTTPS redirect** for Kong service
- **Domain-based routing** for API gateway
- **TCP routing** for PostgreSQL database access
- **Environment variable control** (`EXPOSE_TRAEFIK` for database)

### Re-enabling Traefik

If you want to re-enable Traefik:

1. **Uncomment the labels sections** in docker-compose.yml:
   - Kong service (lines ~55-66)
   - Database service (lines ~400-409)

2. **Update domain names** to match your setup:
   - Replace `your-domain.com` with your actual domain
   - Replace `postgres.your-domain.com` with your database domain

3. **Ensure Traefik is running** in your swarm with proper configuration

4. **Configure entrypoints and middleware** in your Traefik setup

5. **Set environment variable** (optional):
   ```bash
   EXPOSE_TRAEFIK=true
   ```

### Monitoring

```bash
# Check service health
docker stack services supabase

# View logs
docker service logs -f supabase_studio
docker service logs -f supabase_kong
docker service logs -f supabase_db
```

## 🐛 Troubleshooting

### Common Issues (and how to fix them!)

1. **Services not starting**: Check external volumes and networks exist
2. **Database connection issues**: Verify POSTGRES_PASSWORD and network connectivity
3. **API key errors**: Regenerate keys using the official generator
4. **Storage issues**: Check S3 credentials and bucket permissions
5. **Email not working**: Verify SMTP settings and credentials

> 💡 **Pro tip**: Most issues are related to environment variables or network connectivity. Double-check your `.env` file!

### Debug Commands

```bash
# Check service status
docker stack services supabase

# Inspect service
docker service inspect supabase_studio

# Check logs
docker service logs supabase_studio --tail 100

# Connect to container
docker exec -it $(docker ps -q -f name=supabase_studio) sh
```

## 📚 Additional Resources

- [Supabase Self-Hosting Documentation](https://supabase.com/docs/guides/self-hosting)
- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Supabase API Key Generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)

## 🤝 Contributing

This configuration was developed through extensive trial and error (and probably a few cups of coffee ☕). If you find improvements or fixes, please contribute back to help others avoid the same pain points! Every contribution makes this project better for everyone.

### How to Contribute
- 🐛 Found a bug? Open an issue!
- 💡 Have an improvement? Submit a PR!
- 📚 Documentation needs work? We'd love your help!
- ⭐ Star the repo if it helped you!

## ⚠️ Disclaimer

This configuration is provided as-is based on production experience. Always test thoroughly in your environment before deploying to production. The official Supabase guides may be updated in the future, so check for newer versions.

> 🎯 **Goal**: Make Supabase self-hosting with Docker Swarm as painless as possible!

## 📄 License

This configuration is provided under the same license as Supabase (Apache 2.0 License).
