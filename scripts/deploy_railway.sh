#!/bin/bash

# DeepAgent Railway Deployment Script
# This script automates the Railway deployment setup process

set -e

echo "🚀 Starting DeepAgent Railway Deployment Setup..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    curl -fsSL https://railway.app/install.sh | sh
    export PATH="$PATH:/usr/local/bin"
fi

echo "✅ Railway CLI version: $(railway --version)"

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo "🔐 Please login to Railway first:"
    echo "   railway login"
    exit 1
fi

echo "👤 Logged in as: $(railway whoami)"

# Create or link to Railway project
echo "🏗️  Setting up Railway project..."

# Check if railway.toml exists and link to project
if [ -f "railway.toml" ]; then
    echo "📋 Found railway.toml, linking to existing project..."
    railway link
else
    echo "🆕 Creating new Railway project..."
    railway init
fi

# Deploy PostgreSQL service
echo "🐘 Setting up PostgreSQL database..."
railway add --database postgres

# Deploy Redis service  
echo "🔴 Setting up Redis cache..."
railway add --database redis

# Set environment variables
echo "🔧 Configuring environment variables..."

# Generate a secure secret key if not provided
if [ -z "$SECRET_KEY" ]; then
    SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
fi

railway variables set SECRET_KEY="$SECRET_KEY"
railway variables set DJANGO_SETTINGS_MODULE="deepagent.settings.production"
railway variables set ALLOWED_HOSTS="*"
railway variables set DEBUG="False"

# Deploy the web service
echo "🌐 Deploying web service..."
railway up --detach

# Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
sleep 30

# Run database migrations
echo "🗄️  Running database migrations..."
railway run python manage.py migrate

# Create superuser if needed (optional)
if [ "$CREATE_SUPERUSER" = "true" ]; then
    echo "👤 Creating Django superuser..."
    railway run python manage.py createsuperuser --noinput --username admin --email admin@deepagent.com || true
fi

# Check deployment status
echo "🔍 Checking deployment status..."
railway status

# Get the deployment URL
DEPLOYMENT_URL=$(railway status --json | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('deployments', [{}])[0].get('url', 'Not available'))" 2>/dev/null || echo "URL not available")

echo "✅ Deployment completed successfully!"
echo "🌍 Your application is available at: $DEPLOYMENT_URL"
echo "🏥 Health check endpoint: $DEPLOYMENT_URL/health/"

# Test health endpoint
if [ "$DEPLOYMENT_URL" != "Not available" ] && [ "$DEPLOYMENT_URL" != "URL not available" ]; then
    echo "🩺 Testing health endpoint..."
    sleep 10
    if curl -f "$DEPLOYMENT_URL/health/" > /dev/null 2>&1; then
        echo "✅ Health check passed!"
    else
        echo "⚠️  Health check failed - please check logs with: railway logs"
    fi
fi

echo "🎉 Railway deployment setup complete!"
echo ""
echo "Next steps:"
echo "1. Check logs: railway logs"
echo "2. Monitor status: railway status"
echo "3. Access shell: railway shell"
echo "4. View in dashboard: https://railway.app/dashboard"
