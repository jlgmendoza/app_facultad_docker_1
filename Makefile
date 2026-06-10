.PHONY: help up down logs build clean restart shell db-shell test

DOCKER_COMPOSE := docker-compose
DOCKER := docker

# Variables
PROJECT_NAME := proyecto_facultad
APP_CONTAINER := facultad_app
DB_CONTAINER := facultad_db

help:
	@echo "🐳 Comandos disponibles para Docker"
	@echo "===================================="
	@echo ""
	@echo "Gestión de servicios:"
	@echo "  make up              - Iniciar todos los servicios"
	@echo "  make down            - Detener todos los servicios"
	@echo "  make restart         - Reiniciar los servicios"
	@echo "  make ps              - Ver estado de los contenedores"
	@echo ""
	@echo "Construcción:"
	@echo "  make build           - Construir las imágenes (sin caché)"
	@echo "  make build-cache     - Construir usando caché"
	@echo ""
	@echo "Logs y debugging:"
	@echo "  make logs            - Ver logs de todos los servicios"
	@echo "  make logs-app        - Ver logs de la aplicación"
	@echo "  make logs-db         - Ver logs de la BD"
	@echo "  make shell           - Acceder a bash en la aplicación"
	@echo "  make db-shell        - Acceder a MySQL"
	@echo ""
	@echo "Mantenimiento:"
	@echo "  make clean           - Detener y eliminar volúmenes"
	@echo "  make prune           - Limpiar recursos no usados"
	@echo "  make health          - Verificar salud de los servicios"
	@echo ""
	@echo "Tests:"
	@echo "  make test            - Ejecutar tests"
	@echo "  make lint            - Ejecutar linter"
	@echo ""

# Servicios
up:
	@echo "🚀 Iniciando servicios..."
	$(DOCKER_COMPOSE) up -d
	@sleep 3
	@echo "✅ Servicios iniciados"
	@echo "📍 API: http://localhost:8000"
	@echo "📍 Docs: http://localhost:8000/docs"

down:
	@echo "🛑 Deteniendo servicios..."
	$(DOCKER_COMPOSE) down

restart: down up

ps:
	$(DOCKER_COMPOSE) ps

# Construcción
build:
	@echo "🔨 Construyendo imágenes sin caché..."
	$(DOCKER_COMPOSE) build --no-cache

build-cache:
	@echo "🔨 Construyendo imágenes..."
	$(DOCKER_COMPOSE) build

# Logs
logs:
	$(DOCKER_COMPOSE) logs -f

logs-app:
	$(DOCKER_COMPOSE) logs -f app

logs-db:
	$(DOCKER_COMPOSE) logs -f db

# Debugging
shell:
	@echo "💻 Accediendo a bash en la aplicación..."
	$(DOCKER_COMPOSE) exec app bash

db-shell:
	@echo "🗄️  Accediendo a MySQL..."
	$(DOCKER_COMPOSE) exec db mysql -u facultad_user -p

# Información
health:
	@echo "📊 Estado de los servicios:"
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "Estadísticas de recursos:"
	@$(DOCKER) stats --no-stream

# Limpieza
clean:
	@echo "🗑️  Eliminando servicios y volúmenes..."
	$(DOCKER_COMPOSE) down -v
	@echo "✅ Limpio completo realizado"

prune:
	@echo "🧹 Limpiando recursos no usados..."
	$(DOCKER) container prune -f
	$(DOCKER) image prune -f
	$(DOCKER) volume prune -f
	@echo "✅ Limpieza realizada"

# Tests
test:
	@echo "🧪 Ejecutando tests..."
	$(DOCKER_COMPOSE) exec app python -m pytest tests/ -v || true

lint:
	@echo "🔍 Ejecutando linter..."
	$(DOCKER_COMPOSE) exec app flake8 . || true

# Utilidades
validate:
	@echo "✓ Validando docker-compose.yml..."
	$(DOCKER_COMPOSE) config > /dev/null
	@echo "✅ Configuración válida"

env:
	@if [ ! -f .env ]; then \
		echo "📝 Creando .env..."; \
		cp .env.example .env; \
		echo "✅ .env creado. Edítalo si necesitas cambiar configuraciones."; \
	else \
		echo "✓ .env ya existe"; \
	fi

view-env:
	@echo "📋 Variables de entorno actuales:"
	@cat .env

.DEFAULT_GOAL := help
