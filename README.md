# 🚀 Enterprise Web Infrastructure Stack: Docker, Proxy & Telemetry

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)

## 📖 Runbook: Servidor de Aplicaciones Web con Docker

Este documento detalla el procedimiento operativo para la administración, despliegue y mantenimiento del servidor de aplicaciones.

---

## 🌐 Servicios Desplegados Actualmente

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Portainer** | https://portainer.victor.servidorgp.somosdelprieto.com | Gestión visual de contenedores |
| **Grafana** | https://grafana.victor.servidorgp.somosdelprieto.com | Dashboards de monitorización |
| **PrietoEats** | https://prietoeats.victor.servidorgp.somosdelprieto.com | Aplicación principal |
| **Meteorología** | https://meteorologia.victor.servidorgp.somosdelprieto.com | App meteorológica |
| **Meteorología Admin** | https://meteorologia-admin.victor.servidorgp.somosdelprieto.com | PHPMyAdmin |

---

## 🔧 Arquitectura de Red

`
                    ┌─────────────────────────────────────────┐
                    │           INTERNET (HTTPS 443)          │
                    └─────────────────┬───────────────────────┘
                                      │
                    ┌─────────────────▼───────────────────────┐
                    │           nginx-proxy                    │
                    │     (Reverse Proxy + SSL Auto)          │
                    │         Red: frontend                   │
                    └─────────────────┬───────────────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
┌───────▼───────┐           ┌────────▼────────┐           ┌────────▼────────┐
│   Portainer   │           │   PrietoEats    │           │   Meteorología  │
│   :9000       │           │   :80           │           │   :80           │
│ Red: frontend │           │ Red: frontend   │           │ Red: frontend   │
└───────────────┘           │      + internal │           │      + backend  │
                            └────────┬────────┘           └────────┬────────┘
                                     │                             │
                            ┌────────▼────────┐           ┌────────▼────────┐
                            │  PostgreSQL DB  │           │    MariaDB      │
                            │  Red: internal  │           │  Red: backend   │
                            └─────────────────┘           └─────────────────┘
`

**Redes Docker:**
- **frontend**: Red externa para servicios web accesibles via nginx-proxy
- **backend**: Red privada para servicios internos (BD, Prometheus, etc.)

---

## 📦 CÓMO DESPLEGAR UNA NUEVA APLICACIÓN

### Paso 1: Crear estructura de archivos

`
mi-nueva-app/
├── docker-compose.yml
├── .env
├── public/           # (opcional) archivos web
└── src/              # (opcional) código fuente
`

### Paso 2: Crear docker-compose.yml

#### Ejemplo: Aplicación PHP con Base de Datos

`yaml
services:
  # ═══════════════════════════════════════════════════════════
  # BASE DE DATOS
  # ═══════════════════════════════════════════════════════════
  db:
    image: mariadb:11
    container_name: miapp_mysql
    restart: unless-stopped
    environment:
      MARIADB_ROOT_PASSWORD: \
      MARIADB_DATABASE: \
      MARIADB_USER: \
      MARIADB_PASSWORD: \
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mariadb-admin", "ping", "-h", "localhost", "-u", "root", "-p\"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 60s

  # ═══════════════════════════════════════════════════════════
  # APLICACIÓN PHP
  # ═══════════════════════════════════════════════════════════
  app:
    image: php:8.2-apache
    container_name: miapp_php
    restart: unless-stopped
    environment:
      # Variables de la app
      DB_HOST: db
      DB_PORT: 3306
      DB_DATABASE: \
      DB_USERNAME: \
      DB_PASSWORD: \
      # Variables para nginx-proxy (OBLIGATORIAS)
      VIRTUAL_HOST: miapp.victor.servidorgp.somosdelprieto.com
      VIRTUAL_PORT: "80"
      LETSENCRYPT_HOST: miapp.victor.servidorgp.somosdelprieto.com
    volumes:
      - ./public:/var/www/html
      - ./src:/var/www/src
    depends_on:
      - db
    networks:
      - frontend
      - backend

  # ═══════════════════════════════════════════════════════════
  # PHPMYADMIN (Opcional)
  # ═══════════════════════════════════════════════════════════
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: miapp_phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: \
      VIRTUAL_HOST: miapp-admin.victor.servidorgp.somosdelprieto.com
      VIRTUAL_PORT: "80"
      LETSENCRYPT_HOST: miapp-admin.victor.servidorgp.somosdelprieto.com
    networks:
      - frontend
      - backend

# ═══════════════════════════════════════════════════════════
# REDES (OBLIGATORIO usar external: true)
# ═══════════════════════════════════════════════════════════
networks:
  frontend:
    external: true
  backend:
    external: true

# ═══════════════════════════════════════════════════════════
# VOLÚMENES
# ═══════════════════════════════════════════════════════════
volumes:
  mysql_data:
`

### Paso 3: Crear archivo .env

`nv
# ═══════════════════════════════════════════════════════════
# CONFIGURACIÓN DE BASE DE DATOS
# ═══════════════════════════════════════════════════════════
DB_ROOT_PASSWORD=root_password_segura
DB_DATABASE=mi_base_de_datos
DB_USERNAME=mi_usuario
DB_PASSWORD=mi_password_segura

# ═══════════════════════════════════════════════════════════
# CONFIGURACIÓN DE LA APLICACIÓN
# ═══════════════════════════════════════════════════════════
APP_ENV=production
APP_DEBUG=false
`

### Paso 4: Subir al servidor

`ash
# Desde tu PC local
scp -r -P 2241 ./mi-nueva-app victor@www.servidorgp.somosdelprieto.com:~/apps/
`

### Paso 5: Desplegar

`ash
# Conectar al servidor
ssh -p 2241 victor@www.servidorgp.somosdelprieto.com

# Ir a la carpeta y desplegar
cd ~/apps/mi-nueva-app
docker compose up -d

# Verificar que está corriendo
docker ps | grep miapp
`

---

## ⚠️ VARIABLES OBLIGATORIAS PARA NGINX-PROXY

Para que tu aplicación sea accesible via HTTPS, **DEBE** tener estas variables de entorno:

`yaml
environment:
  VIRTUAL_HOST: tu-subdominio.victor.servidorgp.somosdelprieto.com
  VIRTUAL_PORT: "80"
  LETSENCRYPT_HOST: tu-subdominio.victor.servidorgp.somosdelprieto.com
`

Y estar conectado a la red **frontend**:

`yaml
networks:
  - frontend
`

---

## 🔍 Ejemplo: Aplicación Simple (Solo HTML/Nginx)

`yaml
services:
  web:
    image: nginx:alpine
    container_name: mi-web-simple
    environment:
      VIRTUAL_HOST: miweb.victor.servidorgp.somosdelprieto.com
      VIRTUAL_PORT: "80"
      LETSENCRYPT_HOST: miweb.victor.servidorgp.somosdelprieto.com
    volumes:
      - ./html:/usr/share/nginx/html:ro
    networks:
      - frontend

networks:
  frontend:
    external: true
`

---

## 🔧 Comandos Útiles

`ash
# Ver todos los contenedores
docker ps -a

# Ver logs de un contenedor
docker logs -f nombre_contenedor

# Reiniciar nginx-proxy (después de añadir nueva app)
docker restart nginx-proxy

# Verificar redes
docker network ls
docker network inspect frontend

# Limpiar recursos no usados
docker system prune -f

# Ver espacio en disco
df -h
`

---

## 📊 Monitorización

- **Grafana**: https://grafana.victor.servidorgp.somosdelprieto.com
- **Prometheus URL** (para configurar en Grafana): `http://prometheus:9090`

---

## 🔐 Conexión al Servidor

`ash
ssh -p 2241 victor@www.servidorgp.somosdelprieto.com
# Password: Prieto*2
`

---

## 📝 Notas Importantes

1. **NO uses localhost** en VIRTUAL_HOST, causa conflictos
2. **Siempre usa xternal: true** en las redes frontend/backend
3. **El puerto interno** de tu app debe coincidir con VIRTUAL_PORT
4. **Espera 30-60 segundos** después de desplegar para que se genere el certificado SSL
5. **Si usas PHP con rutas**, necesitas .htaccess con mod_rewrite habilitado

