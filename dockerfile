# Usamos la imagen oficial de Nginx
FROM nginx:alpine

# Borramos la configuración por defecto de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiamos tu archivo de configuración personalizado al contenedor
# (Asegúrate de que el nombre del archivo sea exacto)
COPY proxy.conf /etc/nginx/conf.d/proxy.conf

# Exponemos los puertos típicos
EXPOSE 80
EXPOSE 443