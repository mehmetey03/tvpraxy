# Official Python 3.12 slim image
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (Render.com will use $PORT)
EXPOSE 10000

# Optimized Gunicorn configuration for proxy server:
# - 4 worker processes
# - Sync worker class (better for I/O bound apps)
# - 120s timeout for streaming
# - Keep-alive for persistent connections
CMD ["gunicorn", "app:app", \
    "--bind", "0.0.0.0:$PORT", \
    "--workers", "4", \
    "--worker-class", "sync", \
    "--timeout", "120", \
    "--keep-alive", "5", \
    "--max-requests", "1000", \
    "--access-logfile", "-", \
    "--error-logfile", "-", \
    "--log-level", "info"]
