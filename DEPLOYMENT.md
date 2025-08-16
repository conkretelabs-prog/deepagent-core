# DeepAgent Core - Railway Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the DeepAgent Core backend service to Railway with PostgreSQL, Redis, and Celery workers.

## Prerequisites
- Railway account
- GitHub repository access
- Basic understanding of Django and Celery

## Deployment Architecture
The deployment consists of the following services:
- **Web Service**: Django application with Gunicorn
- **Worker Service**: Celery workers for background tasks
- **Scheduler Service**: Celery Beat for periodic tasks
- **PostgreSQL**: Primary database
- **Redis**: Cache and message broker

## Quick Deploy

### Option 1: One-Click Deploy (Recommended)
1. Click the Railway deploy button (when available)
2. Connect your GitHub account
3. Select this repository
4. Railway will automatically detect the configuration from `railway.toml`

### Option 2: Manual Deployment

#### Step 1: Create Railway Project
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Create new project
railway init
```

#### Step 2: Add Services
```bash
# Add PostgreSQL
railway add postgresql

# Add Redis
railway add redis
```

#### Step 3: Configure Environment Variables
Set the following environment variables in Railway dashboard:

**Required Variables:**
- `DJANGO_SETTINGS_MODULE=deepagent.settings.production`
- `SECRET_KEY=your-secret-key-here`
- `DATABASE_URL=${{Postgres.DATABASE_URL}}`
- `REDIS_URL=${{Redis.REDIS_URL}}`
- `CELERY_BROKER_URL=${{Redis.REDIS_URL}}`
- `CELERY_RESULT_BACKEND=${{Redis.REDIS_URL}}`

**Optional Variables:**
- `SENTRY_DSN=your-sentry-dsn`
- `DEBUG=False`
- `ALLOWED_HOSTS=*`

#### Step 4: Deploy
```bash
# Deploy the application
railway up
```

## Service Configuration

### Web Service
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `python manage.py migrate && python manage.py collectstatic --noinput && gunicorn deepagent.wsgi:application --bind 0.0.0.0:$PORT`
- **Health Check**: `/health/`
- **Port**: Automatically assigned by Railway

### Worker Service
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `celery -A deepagent worker --loglevel=info --concurrency=2`
- **Auto-scaling**: Enabled (1-5 replicas)

### Scheduler Service
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `celery -A deepagent beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler`
- **Replicas**: 1 (singleton)

## Monitoring and Health Checks

### Health Check Endpoint
The application provides a comprehensive health check at `/health/` that monitors:
- Database connectivity
- Redis connectivity
- Celery worker status
- Overall system health

### Automated Tasks
The system runs the following automated tasks:
- **Deployment Monitoring**: Every 5 minutes
- **GitHub Issue Checking**: Every 10 minutes
- **Service Health Checks**: Every 3 minutes

## Troubleshooting

### Common Issues

#### 1. Database Connection Errors
```bash
# Check database service status
railway status

# Restart database service if needed
railway restart postgresql
```

#### 2. Redis Connection Issues
```bash
# Verify Redis service
railway logs redis

# Check Redis connectivity
railway run python manage.py shell
>>> from django.core.cache import cache
>>> cache.set('test', 'value')
>>> cache.get('test')
```

#### 3. Celery Worker Issues
```bash
# Check worker logs
railway logs worker

# Restart workers
railway restart worker
```

#### 4. Static Files Not Loading
Ensure `STATIC_ROOT` and `STATICFILES_DIRS` are properly configured in settings.

### Logs and Debugging
```bash
# View application logs
railway logs web

# View worker logs
railway logs worker

# View scheduler logs
railway logs scheduler

# Follow logs in real-time
railway logs --follow
```

## Security Considerations

1. **Environment Variables**: Never commit sensitive data to the repository
2. **ALLOWED_HOSTS**: Configure properly for production
3. **CSRF Protection**: Ensure `CSRF_TRUSTED_ORIGINS` is set
4. **Database Security**: Use strong passwords and connection encryption
5. **API Keys**: Store all API keys as environment variables

## Performance Optimization

### Database
- Enable connection pooling
- Configure appropriate connection limits
- Regular database maintenance

### Redis
- Configure appropriate memory limits
- Enable persistence for critical data
- Monitor memory usage

### Celery
- Adjust worker concurrency based on workload
- Monitor task queue lengths
- Configure appropriate retry policies

## Scaling

### Horizontal Scaling
- Web service: Auto-scales based on traffic
- Workers: Scale from 1-5 replicas based on queue length
- Database: Managed by Railway

### Vertical Scaling
- Upgrade Railway plan for more resources
- Monitor resource usage in Railway dashboard

## Backup and Recovery

### Database Backups
- Railway provides automatic daily backups
- Manual backups can be created via Railway CLI

### Configuration Backup
- All configuration is stored in `railway.toml`
- Environment variables should be documented

## Support and Maintenance

### Regular Tasks
1. Monitor application logs
2. Check health endpoints
3. Review performance metrics
4. Update dependencies regularly

### Emergency Procedures
1. Check Railway status page
2. Review application logs
3. Restart services if needed
4. Contact Railway support if infrastructure issues

## Additional Resources
- [Railway Documentation](https://docs.railway.com/)
- [Django Deployment Guide](https://docs.djangoproject.com/en/4.2/howto/deployment/)
- [Celery Documentation](https://docs.celeryproject.org/)
