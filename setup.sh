#!/bin/bash

# =============================================================================
# SUPABASE DOCKER COMPOSE SETUP SCRIPT
# =============================================================================
# This script initializes all external resources needed for Supabase Docker Compose
# to work without Portainer. It creates volumes, networks, and configs.
#
# Usage: ./setup.sh [--swarm|--compose]
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default mode
MODE="compose"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --swarm)
      MODE="swarm"
      shift
      ;;
    --compose)
      MODE="compose"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--swarm|--compose]"
      echo "  --swarm    Setup for Docker Swarm deployment"
      echo "  --compose  Setup for Docker Compose deployment (default)"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🚀 Supabase Docker Setup Script${NC}"
echo -e "${BLUE}Mode: ${MODE}${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Docker is running"

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f "environment-variables.txt" ]; then
        cp environment-variables.txt .env
        print_status "Created .env from environment-variables.txt"
        print_warning "Please edit .env file with your actual values before running docker-compose"
    else
        print_error "environment-variables.txt template not found"
        exit 1
    fi
else
    print_status ".env file found"
fi

# Create external network
echo ""
echo -e "${BLUE}Creating external network...${NC}"
if docker network ls | grep -q "supabase_overlay"; then
    print_warning "Network 'supabase_overlay' already exists"
else
    docker network create supabase_overlay
    print_status "Created network 'supabase_overlay'"
fi

# Create external volumes
echo ""
echo -e "${BLUE}Creating external volumes...${NC}"

volumes=(
    "supabase-production-storage-data"
    "supabase-production-functions-data"
    "supabase-production-db-data"
    "supabase-production-db-config"
)

for volume in "${volumes[@]}"; do
    if docker volume ls | grep -q "$volume"; then
        print_warning "Volume '$volume' already exists"
    else
        docker volume create "$volume"
        print_status "Created volume '$volume'"
    fi
done

# Create external configs (Docker Swarm only)
if [ "$MODE" = "swarm" ]; then
    echo ""
    echo -e "${BLUE}Creating external configs for Docker Swarm...${NC}"
    
    # Check if we're in a swarm
    if ! docker info | grep -q "Swarm: active"; then
        print_error "Docker Swarm is not active. Please initialize swarm first:"
        echo "  docker swarm init"
        exit 1
    fi
    
    # Create configs from files in volumes directory
    configs=(
        "99-logs.sql:volumes/db/logs.sql"
        "99-realtime.sql:volumes/db/realtime.sql"
        "99-roles.sql:volumes/db/roles.sql"
        "98-webhooks.sql:volumes/db/webhooks.sql"
        "99-jwt.sql:volumes/db/jwt.sql"
        "97-_supabase.sql:volumes/db/_supabase.sql"
        "99-pooler.sql:volumes/db/pooler.sql"
        "vector.yml:volumes/logs/vector.yml"
        "kong.yml:volumes/api/kong.yml"
        "main.ts:volumes/functions/main/index.ts"
    )
    
    for config in "${configs[@]}"; do
        IFS=':' read -r config_name file_path <<< "$config"
        
        if docker config ls | grep -q "$config_name"; then
            print_warning "Config '$config_name' already exists"
        else
            if [ -f "$file_path" ]; then
                docker config create "$config_name" "$file_path"
                print_status "Created config '$config_name'"
            else
                print_error "File '$file_path' not found for config '$config_name'"
            fi
        fi
    done
fi

# Create alternative docker-compose.yml for non-swarm users
if [ "$MODE" = "compose" ]; then
    echo ""
    echo -e "${BLUE}Creating docker-compose.override.yml for Docker Compose...${NC}"
    
    cat > docker-compose.override.yml << 'EOF'
# Docker Compose override file for non-swarm deployments
# This file converts external volumes, networks, and configs to local ones

version: '3.8'

services:
  # Override Kong to use local config file instead of external config
  kong:
    configs:
      - source: kong_config
        target: /home/kong/temp.yml
    volumes:
      - ./volumes/api/kong.yml:/home/kong/temp.yml:ro

  # Override database to use local SQL files instead of external configs
  db:
    configs: []
    volumes:
      - supabase-production-db-data:/var/lib/postgresql/data:Z
      - supabase-production-db-config:/etc/postgresql-custom
      - ./volumes/db/logs.sql:/docker-entrypoint-initdb.d/migrations/99-logs.sql:ro
      - ./volumes/db/realtime.sql:/docker-entrypoint-initdb.d/migrations/99-realtime.sql:ro
      - ./volumes/db/roles.sql:/docker-entrypoint-initdb.d/init-scripts/99-roles.sql:ro
      - ./volumes/db/webhooks.sql:/docker-entrypoint-initdb.d/init-scripts/98-webhooks.sql:ro
      - ./volumes/db/jwt.sql:/docker-entrypoint-initdb.d/init-scripts/99-jwt.sql:ro
      - ./volumes/db/_supabase.sql:/docker-entrypoint-initdb.d/migrations/97-_supabase.sql:ro
      - ./volumes/db/pooler.sql:/docker-entrypoint-initdb.d/migrations/99-pooler.sql:ro

  # Override functions to use local files instead of external configs
  functions:
    configs: []
    volumes:
      - supabase-production-functions-data:/home/deno/functions:Z
      - ./volumes/functions/main/index.ts:/home/deno/functions/main/index.ts:ro

  # Override vector to use local config file instead of external config
  vector:
    configs: []
    volumes:
      - ${DOCKER_SOCKET_LOCATION}:/var/run/docker.sock:ro
      - ./volumes/logs/vector.yml:/etc/vector/vector.yml:ro

# Convert external volumes to local volumes
volumes:
  supabase-production-storage-data:
  supabase-production-functions-data:
  supabase-production-db-data:
  supabase-production-db-config:

# Convert external network to local network
networks:
  supabase_overlay:

# Remove external configs section (not needed for Docker Compose)
EOF

    print_status "Created docker-compose.override.yml"
fi

# Generate secrets if they don't exist
echo ""
echo -e "${BLUE}Checking for required secrets...${NC}"

# Check if JWT_SECRET is set in .env
if grep -q "JWT_SECRET=your-super-secret-jwt-token-exactly-40-characters-long" .env; then
    print_warning "JWT_SECRET needs to be generated"
    echo "Run: openssl rand -hex 20"
fi

# Check if POSTGRES_PASSWORD is set
if grep -q "POSTGRES_PASSWORD=your-super-secret-and-long-postgres-password" .env; then
    print_warning "POSTGRES_PASSWORD needs to be generated"
    echo "Run: openssl rand -base64 32"
fi

# Check if API keys are set
if grep -q "ANON_KEY=your-anon-key-here" .env; then
    print_warning "ANON_KEY needs to be generated"
    echo "Visit: https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys"
fi

if grep -q "SERVICE_ROLE_KEY=your-service-role-key-here" .env; then
    print_warning "SERVICE_ROLE_KEY needs to be generated"
    echo "Visit: https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys"
fi

echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit .env file with your actual values"
echo "2. Generate required secrets (see warnings above)"
echo "3. Deploy with:"
if [ "$MODE" = "swarm" ]; then
    echo "   docker stack deploy -c docker-compose.yml supabase"
else
    echo "   docker-compose up -d"
fi
echo ""
echo -e "${BLUE}Access Supabase Studio at:${NC}"
echo "   http://localhost:8000"
echo ""
echo -e "${BLUE}Default Studio credentials:${NC}"
echo "   Username: supabase"
echo "   Password: this_password_is_insecure_and_should_be_updated"
echo ""
echo -e "${YELLOW}⚠️  Remember to change default passwords in production!${NC}"
