# Usamos una versión estable de Node.js
FROM node:18-alpine

# Creamos el directorio de trabajo
WORKDIR /usr/src/app

# Copiamos los archivos de dependencias
COPY package*.json ./

# Instalamos las dependencias
RUN npm install --production

# Copiamos el resto del código de tu repositorio
COPY . .

# Tu servidor corre en el puerto 3000 (según tu código)
EXPOSE 3000

# Comando para arrancar la app
CMD [ "node", "index.js" ]