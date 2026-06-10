# 🚀 Inicio Rápido - Proyecto Facultad en Lubuntu

## TL;DR (3 pasos)

```bash
# 1. Preparar
cp .env.example .env

# 2. Verificar (opcional pero recomendado)
chmod +x check-docker.sh
./check-docker.sh

# 3. Iniciar
make up
```

Ahora accede a: **http://localhost:8000/docs**

---

## Primeros pasos

### Instalación inicial (primera vez en Lubuntu)

```bash
# 1. Instalar Docker y Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# 2. Agregar tu usuario al grupo docker (evita usar sudo)
sudo usermod -aG docker $USER
newgrp docker

# 3. Verifica
docker --version
docker-compose --version
```

### Configuración del proyecto

```bash
# En el directorio del proyecto
cd ~/ruta/proyecto_facultad

# Copiar configuración
cp .env.example .env

# Instalar make (opcional pero recomendado)
sudo apt-get install -y make
```

---

## Comandos básicos (con Make)

```bash
# Ver todos los comandos
make help

# Iniciar
make up

# Ver logs
make logs

# Detener
make down

# Limpiar todo
make clean
```

## Comandos sin Make

```bash
# Iniciar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Acceder a bash
docker-compose exec app bash

# Acceder a MySQL
docker-compose exec db mysql -u facultad_user -p
```

---

## URLs importantes

| Servicio | URL |
|----------|-----|
| **API Docs** | http://localhost:8000/docs |
| **Swagger UI** | http://localhost:8000/redoc |
| **API Root** | http://localhost:8000/ |
| **MySQL** | localhost:3306 |

### Credenciales MySQL

```
Host: localhost o db (desde el contenedor)
User: facultad_user
Password: facultad_pass
Database: facultad
```

---

## Problemas comunes

### "Permission denied"
```bash
# Agregar permiso
sudo usermod -aG docker $USER
newgrp docker
```

### "Port 3306 already in use"
```bash
# Editar .env y cambiar DB_PORT
nano .env
# Cambiar: DB_PORT=3307
make restart
```

### "Cannot connect to MySQL"
```bash
# Reconstruir
make build
make restart
make logs-db
```

---

## Flujo típico de desarrollo

```bash
# 1. Iniciar servicios (primera vez)
make up

# 2. Ver que funciona
curl http://localhost:8000/docs

# 3. Durante desarrollo
make shell                # Editar código
# Guardar → Se recarga automáticamente

# 4. Ver logs si algo falla
make logs

# 5. Al terminar
make down
```

---

## Documentación completa

Lee `DOCKER_README.md` para una guía completa.

---

**¿Necesitas ayuda?** → Revisa DOCKER_README.md o ejecuta `make help`
