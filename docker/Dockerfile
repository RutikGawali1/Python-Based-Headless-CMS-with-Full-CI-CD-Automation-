FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files into container
COPY . .

# Collect static files (ignore errors if none exist yet)
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# Start Gunicorn server for Django/Wagtail
CMD ["gunicorn", "cms_project.wsgi:application", "--bind", "0.0.0.0:8000", "--workers=2"]
