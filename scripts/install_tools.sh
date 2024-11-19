#!/bin/bash
# configuramos el script para que se muestren los comandos
# y finalice cuando hay un error en la ejecución
set -ex


# importamos el contenido de las variables  de entorno
source .env

# actualiza la lista de paquetes
apt update

# actualizamos los paquetes del sistema operativo
apt upgrade -y

#configuramos las respuestas para la instalación phpmyadmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections


sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

#instalación de adminer
mkdir -p /var/www/html/adminer

#Descargamos el archivo PHP  de adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

#renombramos el archivo
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

# creamos una base de datos de ejemplo
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"

mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"

#instalación de Go access
sudo apt install goaccess -y

#Creamos un directtorio para las estadisticas de GoAccess
mkdir -p /var/www/html/stats

#Go Access
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize