#!/bin/bash

# =============================================================================
# SUPABASE DOCKER SWARM DEPLOYMENT SCRIPT
# =============================================================================
# This script loads environment variables from .env file and deploys to Docker Swarm
# Docker Swarm doesn't support env_file directive, so we need to export variables
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo -e "${BLUE}🚀 Supabase Docker Swarm Deployment${NC}"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo "Please create a .env file from environment-variables.txt template"
    exit 1
fi

print_status "Found .env file"

# Load environment variables from .env file
echo -e "${BLUE}Loading environment variables...${NC}"
set -a  # automatically export all variables
if ! source .env 2>/dev/null; then
    print_error "Failed to load .env file!"
    echo "Common issues:"
    echo "  - Values with spaces must be quoted: VAR=\"value with spaces\""
    echo "  - No spaces around = sign: VAR=value (not VAR = value)"
    echo "  - No special characters without quotes"
    echo ""
    echo "Please check your .env file and try again."
    exit 1
fi
set +a  # stop automatically exporting

print_status "Environment variables loaded"

# Check if Docker Swarm is active
if ! docker info | grep -q "Swarm: active"; then
    print_error "Docker Swarm is not active!"
    echo "Please initialize swarm first: docker swarm init"
    exit 1
fi

print_status "Docker Swarm is active"

# Check if required environment variables are set
required_vars=(
    "POSTGRES_PASSWORD"
    "JWT_SECRET"
    "ANON_KEY"
    "SERVICE_ROLE_KEY"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    print_error "Missing required environment variables:"
    for var in "${missing_vars[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Please set these variables in your .env file"
    exit 1
fi

print_status "Required environment variables are set"

# Deploy the stack
echo -e "${BLUE}Deploying Supabase stack...${NC}"
docker stack deploy -c docker-compose.yml supabase

print_status "Stack deployment initiated"

echo ""
echo -e "${GREEN}🎉 Deployment completed!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Check service status: docker stack services supabase"
echo "2. View logs: docker service logs supabase_db"
echo "3. Access Supabase Studio at: http://localhost:8000"
echo ""
echo -e "${BLUE}Default Studio credentials:${NC}"
echo "   Username: supabase"
echo "   Password: this_password_is_insecure_and_should_be_updated"
echo ""
echo -e "${YELLOW}⚠️  Remember to change default passwords in production!${NC}"
