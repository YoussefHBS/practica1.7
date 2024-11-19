#!/bin/bash
# configuramos el script para que se muestren los comandos
# y finalice cuando hay un error en la ejecución
set -ex


# importamos el contenido de las variables  de entorno
source .env

# Eliminar cargas previas
rm -rf /tmp/wp-cli.phar*

#descargamos la utilidad WP-CLI
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

# le damos permisos de ejecucion
chmod +x /tmp/wp-cli.phar

# Renombramos la utilidad de wp-cli a wp
mv /tmp/wp-cli.phar /usr/local/bin/wp

#Eliminamos instalaciones previas 
rm -rf /var/www/html/*
#descargamos el codigo fuente de wordpress
wp core download \
  --locale=es_ES \
  --path=/var/www/html \
  --allow-root

  #creamos la base de datos y el usuario para worpress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"


  #Creacion del archivo de configuracion
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=/var/www/html \
  --allow-root
#
  wp core install \
  --url=$LE_DOMAIN \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS \
  --admin_email=$WORDPRESS_ADMIN_EMAIL\
  --path=/var/www/html \
  --allow-root  