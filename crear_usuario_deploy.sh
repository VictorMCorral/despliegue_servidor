#!/bin/bash
# Script de automatización para despliegue 

# Solicitar el nombre de usuario de forma interactiva
read -p "Introduce el nombre del nuevo usuario de despliegue: " USER_NAME

# Verificar que no esté vacío
if [ -z "$USER_NAME" ]; then
    echo "Error: El nombre de usuario no puede estar vacío."
    exit 1
fi

# 1. Crear el usuario con su directorio home [cite: 68]
sudo useradd -m -s /bin/bash "$USER_NAME"

# 2. Establecer la contraseña para el acceso SSH 
echo "Configurando contraseña para $USER_NAME (necesaria para SCP/SSH):"
sudo passwd "$USER_NAME"

# 3. Añadir al grupo docker para permitir despliegues sin sudo [cite: 185]
sudo usermod -aG docker "$USER_NAME"

# 4. Crear la estructura de directorios requerida (~/apps/) [cite: 70, 71]
sudo mkdir -p /home/"$USER_NAME"/apps
sudo chown -R "$USER_NAME":"$USER_NAME" /home/"$USER_NAME"/apps

echo "----------------------------------------------------------"
echo "Usuario $USER_NAME creado con éxito."
echo "Directorio para aplicaciones listo en: /home/$USER_NAME/apps/" [cite: 72]
echo "----------------------------------------------------------"

# 5. Cambio de usuario para verificar el entorno [cite: 156]
echo "Cambiando a la sesión de $USER_NAME. Prueba a ejecutar 'docker ps'."
sudo su - "$USER_NAME"
