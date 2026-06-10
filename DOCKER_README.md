# 🐳 Guía de Docker para Proyecto Facultad (Lubuntu)

Este proyecto utiliza Docker y Docker Compose para ejecutar la aplicación FastAPI con MySQL en contenedores. Esta guía está optimizada para **Lubuntu** (Linux ligero).

## 📋 Requisitos previos

### En Lubuntu, instala Docker y Docker Compose:

```bash
# Actualizar repositorios
sudo apt-get update

# Instalar Docker
sudo apt-get install -y docker.io

# Instalar Docker Compose
sudo apt-get install -y docker-compose

# Agregar tu usuario al grupo docker (para usar sin sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalación
docker --version
docker-compose --version
```

## 🚀 Inicio rápido

### 1. Clonar o preparar el proyecto

```bash
cd ~/tu_proyecto
```

### 2. Configurar variables de entorno

```bash
# Copiar template
cp .env.example .env

# Editar si necesitas cambiar valores
nano .env
```

### 3. Opción A: Usar el script (recomendado para Lubuntu)

```bash
# Hacer ejecutable el script
chmod +x docker-start.sh

# Ejecutar el script interactivo
./docker-start.sh
```

### 3. Opción B: Usar Make (recomendado)

```bash
# Ver todos los comandos disponibles
make help

# Iniciar servicios
make up

# Ver logs
make logs

# Acceder a bash
make shell
```

### 3. Opción C: Comandos directos

```bash
# Iniciar servicios en background
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Detener servicios
docker-compose down
```

## 📍 Acceder a los servicios

Después de `make up` o `docker-compose up -d`:

- **API FastAPI**: http://localhost:8000
- **Documentación API**: http://localhost:8000/docs
- **Swagger UI**: http://localhost:8000/redoc
- **Base de datos MySQL**: `localhost:3306`
  - Usuario: `facultad_user`
  - Contraseña: `facultad_pass` (cambiar en .env)

## 📦 Comandos útiles con Make

### Desarrollo

```bash
# Ver estado
make ps

# Ver logs en tiempo real
make logs
make logs-app
make logs-db

# Acceder a bash en la app
make shell

# Acceder a MySQL
make db-shell

# Recargar/reiniciar
make restart
```

### Construcción

```bash
# Reconstruir imágenes (sin caché)
make build

# Reconstruir con caché
make build-cache
```

### Mantenimiento

```bash
# Ver salud de los servicios
make health

# Limpiar todo (con volúmenes)
make clean

# Limpiar recursos no usados
make prune
```

## 🏗️ Estructura de Docker

### Dockerfile

- **Imagen base**: Python 3.14-slim
- **Multi-stage build**: Reduce el tamaño final (~400MB)
- **Usuario no-root**: Usuario `appuser` para mayor seguridad
- **Health checks**: Monitoreo automático

### docker-compose.yml

- **MySQL 8.0**: Base de datos relacional
- **FastAPI**: Aplicación principal
- **Red personalizada**: Aislamiento de servicios
- **Volúmenes**: Persistencia de datos
- **Variables de entorno**: Configuración flexible

### Archivos adicionales

- **init.sql**: Inicialización automática de tablas
- **.env**: Variables de entorno (no subir a Git)
- **.dockerignore**: Exclusiones en la build
- **Makefile**: Atajos para comandos comunes
- **docker-start.sh**: Script interactivo para Lubuntu

## 🔄 Workflow típico en Lubuntu

```bash
# 1. Clonar el proyecto
git clone <repo> proyecto_facultad
cd proyecto_facultad

# 2. Configurar (primera vez)
cp .env.example .env
# Editar .env si necesario

# 3. Iniciar todo
make up

# 4. Ver que funciona
curl http://localhost:8000/docs

# 5. Durante desarrollo
make logs                # Ver logs
make shell              # Editar código
# Guardar cambios → Se recargan automáticamente

# 6. Al terminar
make down               # Detener
```

## 🛠️ Troubleshooting

### Error: "Permission denied" con docker

```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker

# O usar sudo
sudo docker-compose up -d
```

### Error: "Port 3306 already in use"

```bash
# Cambiar en .env
DB_PORT=3307

# O eliminar contenedores viejos
docker-compose down -v
```

### Error: "Cannot connect to MySQL"

```bash
# Ver logs
make logs-db

# Reiniciar completamente
make clean
make up
```

### La app no se conecta a la BD

```bash
# Verificar que el contenedor de BD está healthy
make ps

# Ver logs detallados
make logs-db
make logs-app

# Reconstruir
make build
make up
```

### Python/paquetes no se actualizan

```bash
# Reconstruir sin caché
make build

# Y reiniciar
make restart
```

## 📊 Monitoreo

```bash
# Ver uso de recursos en tiempo real
docker stats

# Ver eventos
docker events

# Inspeccionar un contenedor
docker inspect facultad_app
```

## 📝 Variables de entorno (.env)

```bash
# Base de datos
DB_HOST=db
DB_PORT=3306
DB_NAME=facultad
DB_USER=facultad_user
DB_PASSWORD=facultad_pass
DB_ROOT_PASSWORD=root

# Aplicación
APP_PORT=8000

# FastAPI
DEBUG=False
```

## 🔐 Seguridad

- ✅ Contenedores con usuario no-root
- ✅ Contraseñas en variables de entorno (no hardcoded)
- ✅ .env en .gitignore
- ✅ Network aislada para DB
- ✅ Health checks automáticos

## 📚 Recursos útiles

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MySQL in Docker](https://hub.docker.com/_/mysql)

## 💡 Tips para Lubuntu

### Autocompletar comandos

```bash
# Agregar alias en ~/.bashrc
alias dc='docker-compose'
alias dmake='make'

# Luego
dc up -d
dc logs -f
```

### Ver tamaño de volúmenes

```bash
docker volume ls
docker volume inspect proyecto_facultad_mysql_data
```

### Exportar/importar base de datos

```bash
# Exportar
docker-compose exec db mysqldump -u facultad_user -p facultad > backup.sql

# Importar
cat backup.sql | docker-compose exec -T db mysql -u facultad_user -p facultad
```

---

**Última actualización**: 2026-06-10  
**Versión**: 1.0 - Optimizada para Lubuntu

