# Configuration Guide ⚙️

This guide covers all configuration options for Supabase with Docker, including environment variables, security settings, and advanced configurations.

## 📋 Environment Variables

### Core Configuration

#### Database Settings
```bash
# Database Configuration
POSTGRES_HOST=db                    # Database hostname
POSTGRES_PORT=5432                  # Database port
POSTGRES_DB=postgres                # Database name
POSTGRES_PASSWORD=your-password     # Database password (generate with: openssl rand -base64 32)
```

#### JWT Configuration
```bash
# JWT Configuration
JWT_SECRET=your-40-character-secret # JWT secret (generate with: openssl rand -hex 20)
JWT_EXPIRY=3600                    # JWT expiration time in seconds
```

#### API Keys
```bash
# Supabase API Keys (generate from https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
ANON_KEY=your-anon-key             # Anonymous API key
SERVICE_ROLE_KEY=your-service-key  # Service role API key
```

#### URLs
```bash
# URL Configuration
API_EXTERNAL_URL=http://localhost:8000    # External API URL
SITE_URL=http://localhost:3000            # Site URL for auth redirects
SUPABASE_PUBLIC_URL=http://localhost:8000 # Public Supabase URL
```

### Studio Configuration

```bash
# Studio Settings
STUDIO_DEFAULT_ORGANIZATION=My Organization  # Default organization name
STUDIO_DEFAULT_PROJECT=My Project            # Default project name
OPENAI_API_KEY=your-openai-key               # Optional: OpenAI API key for AI features
```

### Authentication Configuration

#### Signup/Signin Settings
```bash
# Authentication Settings
DISABLE_SIGNUP=false                    # Disable user signup
ENABLE_EMAIL_SIGNUP=true               # Enable email signup
ENABLE_PHONE_SIGNUP=false             # Enable phone signup
ENABLE_ANONYMOUS_USERS=false          # Enable anonymous users
```

#### Email Confirmation
```bash
# Email Confirmation
ENABLE_EMAIL_AUTOCONFIRM=false        # Auto-confirm email signups
ENABLE_PHONE_AUTOCONFIRM=false       # Auto-confirm phone signups
ADDITIONAL_REDIRECT_URLS=             # Additional redirect URLs (comma-separated)
```

### SMTP Configuration

#### Basic SMTP Settings
```bash
# SMTP Configuration
SMTP_ADMIN_EMAIL=noreply@yourdomain.com  # Admin email address
SMTP_HOST=smtp.gmail.com                 # SMTP server hostname
SMTP_PORT=587                            # SMTP server port
SMTP_USER=your-email@gmail.com           # SMTP username
SMTP_PASS=your-app-password              # SMTP password/app password
SMTP_SENDER_NAME=Your App Name           # Sender name for emails
```

#### Email Template Paths
```bash
# Email Template Paths
MAILER_URLPATHS_INVITE=/auth/v1/verify           # Invite email path
MAILER_URLPATHS_CONFIRMATION=/auth/v1/verify     # Confirmation email path
MAILER_URLPATHS_RECOVERY=/auth/v1/verify         # Password recovery path
MAILER_URLPATHS_EMAIL_CHANGE=/auth/v1/verify     # Email change path
```

#### Email Templates (HTML)
```bash
# Email Templates (HTML content)
MAILER_TEMPLATES_INVITE=                         # Invite email template
MAILER_TEMPLATES_CONFIRMATION=                   # Confirmation email template
MAILER_TEMPLATES_RECOVERY=                       # Recovery email template
MAILER_TEMPLATES_MAGIC_LINK=                     # Magic link template
MAILER_TEMPLATES_EMAIL_CHANGE=                   # Email change template
```

#### Email Subjects
```bash
# Email Subjects
MAILER_SUBJECTS_CONFIRMATION=Confirm your signup
MAILER_SUBJECTS_RECOVERY=Reset your password
MAILER_SUBJECTS_MAGIC_LINK=Your magic link
MAILER_SUBJECTS_EMAIL_CHANGE=Confirm your email change
MAILER_SUBJECTS_INVITE=You have been invited
```

### Multi-Factor Authentication (MFA)

```bash
# MFA Configuration
GOTRUE_MFA_PHONE_OTP_LENGTH=6                    # OTP length for phone MFA
GOTRUE_MFA_PHONE_TEMPLATE=Your code is {{ .Code }} # Phone OTP template
GOTRUE_MFA_MAX_ENROLLED_FACTORS=10              # Max enrolled MFA factors
GOTRUE_MFA_TOTP_ENROLL_ENABLED=true            # Enable TOTP enrollment
GOTRUE_MFA_TOTP_VERIFY_ENABLED=true            # Enable TOTP verification
```

### Storage Configuration

#### S3 Configuration
```bash
# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your-access-key               # AWS access key
AWS_SECRET_ACCESS_KEY=your-secret-key           # AWS secret key
AWS_DEFAULT_REGION=us-east-1                   # AWS region
```

#### Storage Settings
```bash
# Storage Settings
FILE_SIZE_LIMIT=52428800                        # Max file size (50MB)
STORAGE_BACKEND=s3                              # Storage backend (s3 or local)
GLOBAL_S3_BUCKET=supabase-storage-bucket       # S3 bucket name
GLOBAL_S3_ENDPOINT=https://s3.amazonaws.com     # S3 endpoint
GLOBAL_S3_PROTOCOL=https                        # S3 protocol
GLOBAL_S3_FORCE_PATH_STYLE=false               # S3 path style
```

#### Image Processing
```bash
# Image Processing
IMGPROXY_ENABLE_WEBP_DETECTION=true             # Enable WebP detection
UPLOAD_SIGNED_URL_EXPIRATION_TIME=10800         # Upload URL expiration (3 hours)
SIGNED_UPLOAD_URL_EXPIRATION_TIME=10800         # Signed upload URL expiration
```

### Analytics & Logging

```bash
# Analytics Configuration
LOGFLARE_API_KEY=your-logflare-key              # Logflare API key
```

### API Gateway (Kong) Configuration

```bash
# Kong Dashboard
DASHBOARD_USERNAME=admin                        # Kong dashboard username
DASHBOARD_PASSWORD=your-password                # Kong dashboard password
```

### Edge Functions

```bash
# Edge Functions
FUNCTIONS_VERIFY_JWT=true                       # Verify JWT in functions
```

### Database Schemas

```bash
# PostgREST Schemas
PGRST_DB_SCHEMAS=public,storage,graphql_public  # Database schemas to expose
```

### Docker Configuration

```bash
# Docker Settings
DOCKER_SOCKET_LOCATION=/var/run/docker.sock     # Docker socket location
```

## 🔒 Security Configuration

### Production Security Checklist

- [ ] **Change Default Passwords**
  ```bash
  # Generate strong passwords
  openssl rand -base64 32  # For POSTGRES_PASSWORD
  openssl rand -base64 16  # For DASHBOARD_PASSWORD
  ```

- [ ] **Generate New JWT Secret**
  ```bash
  # Generate 40-character JWT secret
  openssl rand -hex 20
  ```

- [ ] **Regenerate API Keys**
  - Visit [Supabase API Key Generator](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
  - Use your JWT secret
  - Generate both ANON_KEY and SERVICE_ROLE_KEY

- [ ] **Configure SMTP**
  - Set up email provider (Gmail, SendGrid, etc.)
  - Use app passwords or API keys
  - Test email functionality

- [ ] **Set Up S3 Storage**
  - Create S3 bucket
  - Create IAM user with S3 permissions
  - Generate access keys

- [ ] **Enable HTTPS**
  - Configure SSL certificates
  - Update URLs to use HTTPS
  - Set up reverse proxy if needed

### Security Best Practices

1. **Use Strong Passwords**: Minimum 32 characters for database passwords
2. **Rotate Secrets Regularly**: Change JWT secrets and API keys periodically
3. **Limit Access**: Use firewall rules to restrict access
4. **Monitor Logs**: Set up log monitoring and alerting
5. **Keep Updated**: Regularly update Docker images and dependencies

## 🌐 SMTP Provider Configuration

### Gmail
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password  # Generate app password in Gmail settings
```

### SendGrid
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=your-sendgrid-api-key
```

### Mailgun
```bash
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=your-mailgun-username
SMTP_PASS=your-mailgun-password
```

### AWS SES
```bash
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=your-ses-access-key
SMTP_PASS=your-ses-secret-key
```

## 🗄️ Storage Provider Configuration

### AWS S3
```bash
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-east-1
GLOBAL_S3_BUCKET=your-bucket-name
GLOBAL_S3_ENDPOINT=https://s3.amazonaws.com
```

### MinIO (S3-compatible)
```bash
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-east-1
GLOBAL_S3_BUCKET=your-bucket-name
GLOBAL_S3_ENDPOINT=http://your-minio-server:9000
GLOBAL_S3_FORCE_PATH_STYLE=true
```

### DigitalOcean Spaces
```bash
AWS_ACCESS_KEY_ID=your-spaces-key
AWS_SECRET_ACCESS_KEY=your-spaces-secret
AWS_DEFAULT_REGION=nyc3
GLOBAL_S3_BUCKET=your-space-name
GLOBAL_S3_ENDPOINT=https://nyc3.digitaloceanspaces.com
```

## 🔧 Advanced Configuration

### Custom Domains

```bash
# For custom domains
API_EXTERNAL_URL=https://api.yourdomain.com
SITE_URL=https://yourdomain.com
SUPABASE_PUBLIC_URL=https://api.yourdomain.com
```

### Load Balancing

```bash
# For load balancer setup
API_EXTERNAL_URL=http://load-balancer:8000
SITE_URL=http://load-balancer:3000
SUPABASE_PUBLIC_URL=http://load-balancer:8000
```

### Development vs Production

#### Development Configuration
```bash
# Development settings
DISABLE_SIGNUP=false
ENABLE_EMAIL_AUTOCONFIRM=true
ENABLE_PHONE_AUTOCONFIRM=true
```

#### Production Configuration
```bash
# Production settings
DISABLE_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
ENABLE_PHONE_AUTOCONFIRM=false
```

## 📊 Monitoring Configuration

### Logflare Setup
1. Sign up at [Logflare](https://logflare.app)
2. Create API key in dashboard
3. Set `LOGFLARE_API_KEY` in environment

### Health Checks
```bash
# Enable health checks (default: enabled)
# Health checks are configured in docker-compose files
```

## 🚀 Performance Tuning

### Database Tuning
```bash
# PostgreSQL settings (in docker-compose)
# These are configured in the database service
```

### Resource Limits
```bash
# Set resource limits in docker-compose
# Example:
# deploy:
#   resources:
#     limits:
#       memory: 2G
#       cpus: '1.0'
```

## 🔄 Environment Management

### Development Environment
```bash
# Copy template
cp environment-variables.txt .env.dev

# Edit for development
nano .env.dev

# Use with Docker Compose
docker-compose -f docker-compose.standalone.yml --env-file .env.dev up -d
```

### Production Environment
```bash
# Copy template
cp environment-variables.txt .env.prod

# Edit for production
nano .env.prod

# Use with Docker Swarm
docker stack deploy -c docker-compose.yml --env-file .env.prod supabase
```

## 💡 Configuration Tips

1. **Start Simple**: Use default configuration first, then customize
2. **Test Changes**: Test configuration changes in development first
3. **Document Changes**: Keep track of configuration changes
4. **Backup Configuration**: Backup your `.env` file
5. **Use Secrets**: Store sensitive data in Docker secrets for production

---

**Need Help?** Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
