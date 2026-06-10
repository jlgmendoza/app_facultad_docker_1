#!/bin/bash

# Script de verificación previa para Lubuntu
# Este script verifica que todo esté listo antes de ejecutar Docker

echo "🔍 Verificación previa para Docker en Lubuntu"
echo "=============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

checks_passed=0
checks_failed=0

# Función para verificar comandos
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name está instalado"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $name NO está instalado"
        ((checks_failed++))
    fi
}

# Función para verificar archivos
check_file() {
    local file=$1
    local name=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name existe"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $name NO existe"
        ((checks_failed++))
    fi
}

echo "📋 Verificando dependencias..."
check_command "docker" "Docker"
check_command "docker-compose" "Docker Compose"
check_command "git" "Git"

echo ""
echo "📋 Verificando archivos del proyecto..."
check_file "Dockerfile" "Dockerfile"
check_file "docker-compose.yml" "docker-compose.yml"
check_file ".dockerignore" ".dockerignore"
check_file "requirements.txt" "requirements.txt"
check_file ".env.example" ".env.example"
check_file "init.sql" "init.sql"
check_file "main_facultad_3.py" "main_facultad_3.py"

echo ""
echo "📋 Verificando permiso de usuario..."
if groups | grep -q docker; then
    echo -e "${GREEN}✓${NC} Usuario tiene acceso a docker"
    ((checks_passed++))
else
    echo -e "${YELLOW}⚠${NC}  Usuario NO tiene acceso a docker (necesitarás sudo)"
    echo "    Ejecuta: sudo usermod -aG docker \$USER"
    ((checks_failed++))
fi

echo ""
echo "📋 Verificando docker daemon..."
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon está corriendo"
    ((checks_passed++))
else
    echo -e "${RED}✗${NC} Docker daemon NO está corriendo"
    echo "    Inicia con: sudo systemctl start docker"
    ((checks_failed++))
fi

echo ""
echo "📋 Verificando conectividad..."
if curl -s https://www.docker.com &> /dev/null; then
    echo -e "${GREEN}✓${NC} Conexión a internet OK"
    ((checks_passed++))
else
    echo -e "${YELLOW}⚠${NC}  Sin conexión a internet (podría afectar descarga de imágenes)"
    ((checks_failed++))
fi

echo ""
echo "📋 Verificando versiones..."
docker --version
docker-compose --version

echo ""
echo "=============================================="
echo "📊 Resumen: ${GREEN}$checks_passed pasadas${NC}, ${RED}$checks_failed fallos${NC}"

if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}✓ Todo está listo para iniciar Docker${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. Configura el .env: cp .env.example .env"
    echo "2. Inicia los servicios: make up"
    echo "3. Verifica los logs: make logs"
    exit 0
else
    echo -e "${RED}✗ Hay problemas que deben ser solucionados${NC}"
    echo ""
    echo "Soluciona los problemas arriba mencionados e intenta de nuevo."
    exit 1
fi
