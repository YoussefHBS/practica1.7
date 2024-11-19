#!/bin/bash

#  Configuramos el script para que se muestren los comandos
# y finalice cuando hay un error en la ejecución

set -ex

# Importamos el archivo .env
source .env

snap install core
snap refresh core

#Eliminamos si existiese alguna instalación previa de certbot con apt.
apt remove certbot -y

# Instalamos el cliente de Certbot con snapd.
snap install --classic certbot

# Creamos una alias para el comando certbot.
ln -fs /snap/bin/certbot /usr/bin/certbot 

# Solicitamos un certificado SSL en let's Encrypt     

certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive
