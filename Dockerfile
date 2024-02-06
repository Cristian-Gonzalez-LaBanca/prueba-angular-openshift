### STAGE 1:BUILD ###
# Defining a node image to be used as giving it an alias of "build"
# Which version of Node image to use depends on project dependencies 
# This is needed to build and compile our code 
# while generating the docker image
FROM node:20 AS build
WORKDIR /app
COPY . /app/
RUN npm install 
RUN npm run build --prod
### STAGE 2:RUN ###
# Defining nginx image to be used
FROM nginx:latest AS ngi

USER root
RUN rm -rf /usr/share/nginx/html/*
RUN apt-get update -y 
#RUN apt-get install vim -y

# Fix ermissions for Nginx
RUN chmod -R 777 /usr/share/nginx/html
# Copying compiled code and nginx config to different folder
# NOTE: This path may change according to your project's output folder 
COPY --from=build /app/dist/prueba-angular /usr/share/nginx/html
# Create necessary directories with proper permissions
RUN mkdir -p /var/cache/nginx/client_temp
RUN chmod -R 777 /var/cache/nginx/client_temp
RUN mkdir -p /var/cache/nginx/proxy_temp
RUN chmod -R 777 /var/cache/nginx/proxy_temp
RUN chmod -R 777 /var
RUN rm -rf /var/cache/nginx/*
# Crear el directorio para el archivo pid y establecer permisos
RUN mkdir -p /var/run/nginx \
    && chmod -R 777 /var/run/nginx
# Crear un archivo pid personalizado y establecer permisos
RUN touch /var/run/nginx.pid \
    && chmod 777 /var/run/nginx.pid
# Crear directorios necesarios con permisos
RUN mkdir -p /var/cache/nginx/client_temp && chmod -R 777 /var/cache/nginx
RUN mkdir -p /var/cache/nginx/proxy_temp && chmod -R 777 /var/cache/nginx/proxy_temp


# Cambiar la configuración de Nginx para escuchar en el puerto 8080
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/listen\(.*\)80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

# Agregar el usuario nginx al grupo que tiene acceso al puerto 80
RUN usermod -aG root nginx

# Exposing a port, here it means that inside the container 
# the app will be using Port 80 while running
EXPOSE 80
EXPOSE 443
USER nginx
CMD [ "nginx","-g","daemon off;"]