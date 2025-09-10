# Imagen base liviana con Python
FROM python:3.12-slim

# Seguridad y performance básicos
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Dependencias del sistema (si luego necesitas gcc, libpq, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Crear usuario no root
RUN useradd -m appuser

# Directorio de la app
WORKDIR /app

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY app ./app

# Exponer puerto interno (Cloud Run detecta el PORT, abajo lo usamos)
ENV PORT=8000

# Cambiar a usuario no root
USER appuser

# Comando de ejecución (uvicorn)
CMD exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT}

