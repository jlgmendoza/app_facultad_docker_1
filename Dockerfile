# Etapa 1: Builder
FROM python:3.14-slim as builder

WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar paquetes Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements.txt
COPY requirements.txt .

# Crear directorio para wheels y compilar dependencias
RUN pip install --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt


# Etapa 2: Runtime
FROM python:3.14-slim

WORKDIR /app

# Instalar solo las dependencias de runtime necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient21 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar wheels desde la etapa builder
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Instalar las dependencias desde wheels
RUN pip install --upgrade pip && \
    pip install --no-cache /wheels/*

# Copiar el código de la aplicación
COPY . .

# Crear usuario no-root para mejorar seguridad
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

# Exponer el puerto (por defecto FastAPI usa 8000)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main_facultad_3:app", "--host", "0.0.0.0", "--port", "8000"]
