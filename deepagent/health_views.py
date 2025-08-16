from django.http import JsonResponse
from django.db import connection
from django.core.cache import cache
import redis
import os
from celery import Celery

def health_check(request):
    """
    Comprehensive health check endpoint for Railway deployment
    """
    health_status = {
        'status': 'healthy',
        'services': {},
        'timestamp': None
    }
    
    # Check database connection
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            health_status['services']['database'] = 'healthy'
    except Exception as e:
        health_status['services']['database'] = f'unhealthy: {str(e)}'
        health_status['status'] = 'unhealthy'
    
    # Check Redis connection
    try:
        cache.set('health_check', 'ok', 30)
        if cache.get('health_check') == 'ok':
            health_status['services']['redis'] = 'healthy'
        else:
            health_status['services']['redis'] = 'unhealthy: cache test failed'
            health_status['status'] = 'unhealthy'
    except Exception as e:
        health_status['services']['redis'] = f'unhealthy: {str(e)}'
        health_status['status'] = 'unhealthy'
    
    # Check Celery worker status
    try:
        from celery import current_app
        inspect = current_app.control.inspect()
        stats = inspect.stats()
        if stats:
            health_status['services']['celery_workers'] = 'healthy'
        else:
            health_status['services']['celery_workers'] = 'no workers available'
    except Exception as e:
        health_status['services']['celery_workers'] = f'unhealthy: {str(e)}'
    
    # Add timestamp
    from datetime import datetime
    health_status['timestamp'] = datetime.now().isoformat()
    
    # Return appropriate HTTP status code
    status_code = 200 if health_status['status'] == 'healthy' else 503
    
    return JsonResponse(health_status, status=status_code)

def simple_health_check(request):
    """
    Simple health check that just returns 200 OK
    """
    return JsonResponse({'status': 'ok'})