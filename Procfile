web: python manage.py migrate && python manage.py collectstatic --noinput && gunicorn deepagent.wsgi:application --bind 0.0.0.0:$PORT
worker: celery -A deepagent worker --loglevel=info --concurrency=2
scheduler: celery -A deepagent beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler
