# DeepAgent Core - Railway Deployment Guide

This guide provides comprehensive instructions for deploying the DeepAgent Core backend service to Railway with PostgreSQL and Redis services.

## 🚀 Quick Start

### Prerequisites
- Railway account ([Sign up here](https://railway.app))
- Git repository access
- Basic knowledge of Django applications

### Automated Deployment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/conkretelabs-prog/deepagent-core.git
   cd deepagent-core
   ```

2. **Run the automated deployment script:**
   ```bash
   chmod +x scripts/deploy_railway.sh
   ./scripts/deploy_railway.sh
   ```

3. **Follow the prompts to login to Railway and configure your deployment.**

## 🔧 Manual Deployment

### Step 1: Install Railway CLI

```bash
# Install Railway CLI
curl -fsSL https://railway.app/install.sh | sh

# Login to Railway
railway login
```

### Step 2: Create Railway Project

```bash
# Initialize new Railway project
railway init

# Or link to existing project
railway link
```

### Step 3: Add Required Services

```bash
# Add PostgreSQL database
railway add --database postgres

# Add Redis cache
railway add --database redis
```

### Step 4: Configure Environment Variables

```bash
# Set required environment variables
railway variables set SECRET_KEY="your-secret-key-here"
railway variables set DJANGO_SETTINGS_MODULE="deepagent.settings.production"
railway variables set ALLOWED_HOSTS="*"
railway variables set DEBUG="False"
```

### Step 5: Deploy Application

```bash
# Deploy the application
railway up

# Run database migrations
railway run python manage.py migrate

# Create superuser (optional)
railway run python manage.py createsuperuser
```

## 🏗️ Service Architecture

The deployment consists of the following services:

### 1. Web Service (Django Application)
- **Framework:** Django 4.2.7
- **WSGI Server:** Gunicorn
- **Health Check:** `/health/` endpoint
- **Static Files:** Served via WhiteNoise

### 2. PostgreSQL Database
- **Version:** PostgreSQL 15
- **Purpose:** Primary data storage
- **Connection:** Via `DATABASE_URL` environment variable

### 3. Redis Cache
- **Version:** Redis 7.0
- **Purpose:** Caching and Celery message broker
- **Connection:** Via `REDIS_URL` environment variable

### 4. Celery Worker (Optional)
- **Purpose:** Background task processing
- **Broker:** Redis
- **Concurrency:** 2 workers by default

### 5. Celery Beat Scheduler (Optional)
- **Purpose:** Periodic task scheduling
- **Scheduler:** Django Celery Beat

## 🔍 Health Monitoring

### Health Check Endpoint
The application provides a comprehensive health check at `/health/`:

```json
{
  "status": "healthy",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "celery_workers": "healthy"
  },
  "timestamp": "2025-08-16T20:41:00.000Z"
}
```

### Monitoring Commands

```bash
# Check deployment status
railway status

# View application logs
railway logs

# Access application shell
railway shell

# Run Django management commands
railway run python manage.py <command>
```

## 🔐 Environment Variables

### Required Variables
- `SECRET_KEY`: Django secret key for cryptographic signing
- `DATABASE_URL`: PostgreSQL connection string (auto-generated)
- `REDIS_URL`: Redis connection string (auto-generated)
- `DJANGO_SETTINGS_MODULE`: Set to `deepagent.settings.production`

### Optional Variables
- `SENTRY_DSN`: Error tracking with Sentry
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts
- `DEBUG`: Set to `False` for production
- `CELERY_BROKER_URL`: Celery message broker URL
- `CELERY_RESULT_BACKEND`: Celery result backend URL

## 🚨 Troubleshooting

### Common Issues

1. **Health Check Failures**
   ```bash
   # Check logs for detailed error information
   railway logs --tail

   # Test database connection
   railway run python manage.py dbshell
   ```

2. **Static Files Not Loading**
   ```bash
   # Collect static files manually
   railway run python manage.py collectstatic --noinput
   ```

3. **Database Migration Issues**
   ```bash
   # Run migrations manually
   railway run python manage.py migrate

   # Check migration status
   railway run python manage.py showmigrations
   ```

4. **Celery Workers Not Starting**
   ```bash
   # Check Celery worker logs
   railway logs --service worker

   # Test Celery connection
   railway run celery -A deepagent inspect ping
   ```

### Debug Commands

```bash
# Access Django shell
railway run python manage.py shell

# Check database tables
railway run python manage.py dbshell

# View environment variables
railway variables

# Test Redis connection
railway run python -c "import redis; r=redis.from_url('$REDIS_URL'); print(r.ping())"
```

## 📊 Performance Optimization

### Recommended Settings

1. **Gunicorn Configuration**
   - Workers: 2-4 (based on CPU cores)
   - Timeout: 120 seconds
   - Keep-alive: 2 seconds

2. **Database Connection Pooling**
   - Enable connection pooling in production
   - Set appropriate `CONN_MAX_AGE` in Django settings

3. **Redis Configuration**
   - Enable persistence for important data
   - Set appropriate memory limits

### Scaling

```bash
# Scale web service replicas
railway scale --replicas 3

# Monitor resource usage
railway metrics
```

## 🔄 Deployment Updates

### Continuous Deployment

1. **Connect GitHub Repository**
   - Link your Railway project to GitHub
   - Enable automatic deployments on push to main branch

2. **Manual Deployment**
   ```bash
   # Deploy latest changes
   railway up

   # Deploy specific branch
   railway up --branch feature-branch
   ```

### Rollback

```bash
# View deployment history
railway deployments

# Rollback to previous deployment
railway rollback <deployment-id>
```

## 📝 Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/)
- [Celery Documentation](https://docs.celeryproject.org/)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Performance_Optimization)

## 🆘 Support

If you encounter issues during deployment:

1. Check the [Railway Status Page](https://status.railway.app/)
2. Review application logs: `railway logs`
3. Join the [Railway Discord](https://discord.gg/railway)
4. Create an issue in this repository

---

**Last Updated:** August 16, 2025
**Version:** 1.0.0
