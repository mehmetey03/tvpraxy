# 1. Usa l'immagine ufficiale Python 3.12 slim (leggera)
FROM python:3.12-slim

# 2. Installa le dipendenze di sistema necessarie
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Imposta la directory di lavoro
WORKDIR /app

# 4. Prima copia solo requirements.txt per caching degli strati Docker
COPY requirements.txt .

# 5. Installa le dipendenze Python
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 6. Ora copia tutto il resto del codice
COPY . .

# 7. Esponi la porta (Render userà la variabile $PORT)
EXPOSE 7860

# 8. Comando di avvio ottimizzato per Render.com
CMD ["gunicorn", "app:app", \
    "--bind", "0.0.0.0:$PORT", \
    "--workers", "4", \
    "--worker-class", "sync", \
    "--timeout", "120", \
    "--keep-alive", "5", \
    "--max-requests", "1000", \
    "--max-requests-jitter", "50", \
    "--access-logfile", "-", \
    "--error-logfile", "-", \
    "--log-level", "info"]
