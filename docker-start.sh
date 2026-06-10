#!/bin/bash

# Script de inicialización para Docker en Lubuntu
# Ejecuta este script para configurar y lanzar la aplicación

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env"

echo "🐳 Proyecto Facultad - Docker Setup para Lubuntu"
echo "=================================================="

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Instálalo primero:"
    echo "   sudo apt-get install docker.io docker-compose"
    exit 1
fi

# Verificar que docker-compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose no está instalado. Instálalo:"
    echo "   sudo apt-get install docker-compose"
    exit 1
fi

# Crear .env si no existe
if [ ! -f "$ENV_FILE" ]; then
    echo "📝 Creando archivo .env..."
    cp "$PROJECT_DIR/.env.example" "$ENV_FILE"
    echo "✅ .env creado. Edítalo si necesitas cambiar configuraciones."
fi

# Cambiar permisos si es necesario
if [ ! -w "/var/run/docker.sock" ]; then
    echo "⚠️  Necesitas permisos para Docker. Ejecutando con sudo..."
    DOCKER_SUDO="sudo"
else
    DOCKER_SUDO=""
fi

cd "$PROJECT_DIR"

# Menu de opciones
echo ""
echo "¿Qué deseas hacer?"
echo "1) Iniciar los servicios (up)"
echo "2) Detener los servicios (down)"
echo "3) Ver logs (logs)"
echo "4) Acceder a MySQL (mysql)"
echo "5) Acceder a la consola de la app (bash)"
echo "6) Verificar estado (ps)"
echo "7) Reconstruir imágenes (build)"
echo "8) Limpiar todo (down -v)"

read -p "Elige una opción (1-8): " option

case $option in
    1)
        echo "🚀 Iniciando servicios..."
        $DOCKER_SUDO docker-compose up -d
        echo "✅ Servicios iniciados"
        echo ""
        echo "📍 Accede a la API en: http://localhost:8000"
        echo "📍 Documentación API: http://localhost:8000/docs"
        echo "📍 Base de datos: localhost:3306"
        echo ""
        echo "Ver logs: $DOCKER_SUDO docker-compose logs -f"
        ;;
    2)
        echo "🛑 Deteniendo servicios..."
        $DOCKER_SUDO docker-compose down
        echo "✅ Servicios detenidos"
        ;;
    3)
        echo "📜 Mostrando logs..."
        $DOCKER_SUDO docker-compose logs -f
        ;;
    4)
        echo "🗄️  Accediendo a MySQL..."
        $DOCKER_SUDO docker-compose exec db mysql -u facultad_user -p
        ;;
    5)
        echo "💻 Abriendo consola de la app..."
        $DOCKER_SUDO docker-compose exec app bash
        ;;
    6)
        echo "📊 Estado de los servicios:"
        $DOCKER_SUDO docker-compose ps
        ;;
    7)
        echo "🔨 Reconstruyendo imágenes..."
        $DOCKER_SUDO docker-compose build --no-cache
        echo "✅ Imágenes reconstruidas"
        ;;
    8)
        echo "🗑️  Eliminando servicios y volúmenes..."
        $DOCKER_SUDO docker-compose down -v
        echo "✅ Todo eliminado (datos perdidos)"
        ;;
    *)
        echo "❌ Opción no válida"
        exit 1
        ;;
esac
