#!/bin/bash
# Script para eliminar usuarios de despliegue y limpiar su rastro

# 1. Solicitar el nombre del usuario a borrar
read -p "Introduce el nombre del usuario que deseas ELIMINAR: " USER_NAME

# Verificar que no esté vacío
if [ -z "$USER_NAME" ]; then
    echo "Error: El nombre de usuario no puede estar vacío."
    exit 1
fi

# 2. Comprobar si el usuario existe
if ! id "$USER_NAME" &>/dev/null; then
    echo "Error: El usuario '$USER_NAME' no existe en el sistema."
    exit 1
fi

# 3. Confirmación de seguridad
echo "ADVERTENCIA: Se borrará el usuario '$USER_NAME' y TODA su carpeta /home/$USER_NAME (incluyendo las apps)."
read -p "¿Estás seguro? (s/n): " CONFIRM
if [[ $CONFIRM != "s" ]]; then
    echo "Operación cancelada."
    exit 0
fi

# 4. Forzar el cierre de procesos del usuario (por si dejó un SSH abierto) 
echo "Cerrando procesos activos de $USER_NAME..."
sudo pkill -u "$USER_NAME"

# 5. Borrar usuario y su directorio home (incluye ~/apps/) [cite: 70, 71]
echo "Eliminando usuario y archivos..."
sudo userdel -r "$USER_NAME"

echo "----------------------------------------------------------"
echo "Usuario '$USER_NAME' eliminado correctamente."
echo "El sistema ha sido limpiado para una nueva configuración."
echo "----------------------------------------------------------"
