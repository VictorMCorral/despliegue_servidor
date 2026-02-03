# 🚀 Enterprise Web Infrastructure Stack: Docker, Proxy & Telemetry

![alt text](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white) 
![alt text](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![alt text](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![alt text](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![alt text](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)


## 📖 Runbook: Servidor de Aplicaciones Web con Docker

Este documento detalla el procedimiento operativo para la administración, despliegue y mantenimiento del servidor de aplicaciones desarrollado para la práctica de **RA2**.

### 1. Requisitos de Red
El servidor opera en una arquitectura de red segmentada para garantizar la seguridad:
*   **Red `frontend`**: Red externa (bridge) donde conviven el Proxy Inverso y los contenedores de aplicaciones que requieren acceso web.
*   **Red `backend`**: Red privada para servicios de infraestructura (Prometheus, Node Exporter) no accesibles desde el exterior.
*   **Resolución DNS**: 
    *   **Local**: Se utiliza un servidor BIND9 para resolver dominios `.2daw` (ej: `apps.victor.2daw`).
    *   **Público**: Se utiliza DuckDNS (`victorm2daw.duckdns.org`) para la validación de certificados SSL reales con acme.
    *   **Publico**: Se utiliza `*.victor2daw.dpdns.org` con cloudflare como puente al exterior suministrando SSL gestionados por este.

### 2. Creación de Usuarios de Despliegue
Para cumplir con la gestión de usuarios y permisos, se incluye un script de automatización `crear_usuario_deploy.sh`.

**Procedimiento:**
1.  Ejecutar el script con permisos de superusuario:
    ```bash
    sudo ./crear_usuario_deploy.sh
    ```
    Si por algun motivo nos equivocamos, podemos lanzar el script de borrar:
    ```bash 
    sudo ./borrar_usuario_deploy.sh
    ```
    
2.  Introducir el nombre del alumno (ej: `victor_pruebas`).
3.  El script automáticamente:
    *   Crea el usuario y su directorio `home`.
    *   Asigna al usuario al grupo `docker`.
    *   Crea la estructura de directorios `~/apps/` con los permisos correctos.

### 3. Procedimiento Estándar de Despliegue
Cualquier aplicación debe seguir este flujo para ser integrada en el sistema:

#### Paso 1: Preparación local (en el PC del alumno)
Crear una carpeta con los archivos de la app y un `docker-compose.yml` siguiendo esta plantilla:
```yaml
services:
  ${USERNAME}:
    image: nginx:alpine
    container_name: web-${USERNAME}-final
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html:ro
    environment:
      - VIRTUAL_HOST=${USERNAME}.victor2daw.dpdns.org
      - VIRTUAL_PORT=80
    networks:
      - frontend

networks:
  frontend:
    external: true
```

#### Paso 2: Envío mediante SCP
Enviar la carpeta al servidor:
```bash
scp -r ./mi-app usuario@192.168.1.152:~/apps/
```

#### Paso 3: Despliegue mediante SSH
Conectar al servidor y levantar el contenedor:
```bash
ssh usuario@192.168.1.152
cd ~/apps/mi-app
docker compose up -d
```

### 4. Gestión de Dominios y HTTPS Real
El servidor implementa **HTTPS Real** mediante dos opciones: 
1. Let's Encrypt: El contenedor `acme-companion` monitoriza las etiquetas `LETSENCRYPT_HOST` y utiliza el `DuckDNS_Token` configurado en el stack principal para emitir los certificados automáticamente.
2. Cloudflare: se despliega de forma norma, ya que dentro de cloudflare ya esta la configuracion general

### 5. Monitorización y Métricas
El sistema de monitorización es accesible vía web sin necesidad de puertos adicionales:
*   **Grafana**: `http://grafana.victor2daw.dpdns.org` (Usuario/Pass configurados).
*   **Prometheus**: `http://prometheus.victor2daw.dpdns.org`.

**Comprobación de métricas:**
1.  Acceder a Grafana.
2.  Consultar el Dashboard **Node Exporter Full (ID: 1860)**.
3.  Verificar que los paneles de CPU, RAM y Red muestran datos coherentes del host.

### 6. Mantenimiento Básico
Comandos esenciales para la operativa diaria:

*   **Ver estado de los servicios**: `docker ps`
*   **Reiniciar el Proxy Inverso**: `docker restart nginx-proxy`
*   **Ver logs de certificados**: `docker logs -f nginx-proxy-acme`
*   **Parar una aplicación**: `cd ~/apps/app-name && docker compose down`
*   **Gestión Visual**: Acceder a `http://portainer.victor2daw.dpdns.org` para administrar contenedores, redes y volúmenes mediante interfaz gráfica.

