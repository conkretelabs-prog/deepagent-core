"""
Celery configuration for deepagent project.
"""
import os
from celery import Celery

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'deepagent.settings.production')

app = Celery('deepagent')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django apps.
app.autodiscover_tasks()

# Celery beat schedule for periodic tasks
app.conf.beat_schedule = {
    'monitor-deployments': {
        'task': 'deepagent.tasks.monitor_deployments',
        'schedule': 300.0,  # Every 5 minutes
    },
    'check-github-issues': {
        'task': 'deepagent.tasks.check_github_issues',
        'schedule': 600.0,  # Every 10 minutes
    },
    'health-check-services': {
        'task': 'deepagent.tasks.health_check_services',
        'schedule': 180.0,  # Every 3 minutes
    },
}

app.conf.timezone = 'UTC'

@app.task(bind=True, ignore_result=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
