# Base image
FROM python:3.11-slim

# Set work directory
WORKDIR /app
ENV PYTHONPATH=/app

# Install system dependencies
RUN apt-get update && apt-get install -y build-essential libpq-dev && rm -rf /var/lib/apt/lists/*

# Copy all project files, including requirements.txt
COPY . .

# Expose the port
EXPOSE 8000

# The command is now in docker-compose.yml
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "mysite.wsgi:application"]