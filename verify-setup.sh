#!/bin/bash

# CHECKLIST DE VERIFICACIÓN DEL SETUP DOCKER
# ============================================

echo "✅ CHECKLIST DE VERIFICACIÓN DEL SETUP DOCKER"
echo "=============================================="
echo ""

CHECKS=0
PASSED=0

# Función para verificar
check() {
    local desc=$1
    local condition=$2
    
    CHECKS=$((CHECKS + 1))
    
    if eval "$condition"; then
        echo "✅ [$CHECKS] $desc"
        PASSED=$((PASSED + 1))
    else
        echo "❌ [$CHECKS] $desc"
    fi
}

# Verificaciones
echo "🔍 Verificando archivos Docker..."
check "Dockerfile existe" "[ -f Dockerfile ]"
check "docker-compose.yml existe" "[ -f docker-compose.yml ]"
check ".dockerignore existe" "[ -f .dockerignore ]"
check "init.sql existe" "[ -f init.sql ]"
check ".env.example existe" "[ -f .env.example ]"

echo ""
echo "🔍 Verificando scripts..."
check "docker-start.sh existe" "[ -f docker-start.sh ]"
check "check-docker.sh existe" "[ -f check-docker.sh ]"
check "Makefile existe" "[ -f Makefile ]"

echo ""
echo "🔍 Verificando documentación..."
check "QUICK_START.md existe" "[ -f QUICK_START.md ]"
check "DOCKER_README.md existe" "[ -f DOCKER_README.md ]"
check "SETUP_SUMMARY.txt existe" "[ -f SETUP_SUMMARY.txt ]"

echo ""
echo "🔍 Verificando proyecto..."
check "main_facultad_3.py existe" "[ -f main_facultad_3.py ]"
check "requirements.txt existe" "[ -f requirements.txt ]"
check "Carpeta templates existe" "[ -d templates ]"
check "Carpeta BBDD existe" "[ -d BBDD ]"

echo ""
echo "🔍 Verificando permisos..."
check "docker-start.sh es ejecutable" "[ -x docker-start.sh ] 2>/dev/null || echo 'false'"
check "check-docker.sh es ejecutable" "[ -x check-docker.sh ] 2>/dev/null || echo 'false'"

echo ""
echo "═══════════════════════════════════════════"
echo "RESULTADO: $PASSED/$CHECKS verificaciones pasadas"
echo "═══════════════════════════════════════════"

if [ $PASSED -eq $CHECKS ]; then
    echo ""
    echo "✨ ¡TODO ESTÁ LISTO!"
    echo ""
    echo "Próximos pasos:"
    echo "  1. Copiar .env: cp .env.example .env"
    echo "  2. Verificar: ./check-docker.sh"
    echo "  3. Iniciar: make up"
    exit 0
else
    echo ""
    echo "⚠️  Faltan $((CHECKS - PASSED)) verificaciones"
    echo ""
    echo "Ejecuta 'chmod +x *.sh' para hacer los scripts ejecutables"
    exit 1
fi
