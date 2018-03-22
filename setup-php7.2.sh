#!/bin/bash

echo "---- Iniciando instalação do ambiente de Desenvolvimento PHP [Ubuntu 16.04] ---"

echo "--- Atualizando lista de pacotes ---"
sudo apt-get update

echo "--- Definindo Senha padrao para o MySQL e suas ferramentas ---"
#password-generator
#https://identitysafe.norton.com/pt-br/password-generator#

DEFAULTPASS="vagrant"
sudo debconf-set-selections <<EOF
mysql-server    mysql-server/root_password password $DEFAULTPASS
mysql-server    mysql-server/root_password_again password $DEFAULTPASS
dbconfig-common dbconfig-common/mysql/app-pass password $DEFAULTPASS
dbconfig-common dbconfig-common/mysql/admin-pass password $DEFAULTPASS
dbconfig-common dbconfig-common/password-confirm password $DEFAULTPASS
dbconfig-common dbconfig-common/app-password-confirm password $DEFAULTPASS
phpmyadmin      phpmyadmin/reconfigure-webserver multiselect nginx
phpmyadmin      phpmyadmin/dbconfig-install boolean true
phpmyadmin      phpmyadmin/app-password-confirm password $DEFAULTPASS 
phpmyadmin      phpmyadmin/mysql/admin-pass     password $DEFAULTPASS
phpmyadmin      phpmyadmin/password-confirm     password $DEFAULTPASS
Phpmyadmin      phpmyadmin/setup-password       password $DEFAULTPASS
phpmyadmin      phpmyadmin/mysql/app-pass       password $DEFAULTPASS
EOF

echo "--- Atualizando lista de pacotes ---"
sudo apt-get update

echo "--- Instalando pacotes basicos ---"
sudo apt-get install software-properties-common vim curl python-software-properties git-core --assume-yes

echo "--- Adicionando repositorio do pacote PHP ---"
sudo add-apt-repository ppa:ondrej/php

echo "--- Instalando MySQL, Phpmyadmin e alguns outros modulos ---"
sudo apt-get install mysql-server --assume-yes
sudo apt-get install phpmyadmin --assume-yes
sudo systemctl status mysql.service

echo "--- Instalando PostgreSQL ---"
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib --assume-yes

echo "--- Instalando PHP e alguns modulos ---"
sudo apt-get install php7.2 php7.2-common php7.2-cli php7.2-fpm php7.2-json php7.2-opcache php7.2-xml --assume-yes
sudo apt-get install libapache2-mod-php7.2 php7.2-mysql php7.2-pgsql php7.2-curl php7.2-dev php7.2-sqlite3 php7.2-mbstring php7.2-gd --assume-yes
sudo apt-get install git zip unzip php-memcached --assume-yes

echo "--- Atualizando lista de pacotes ---"
sudo apt-get update

curl -sS https://getcomposer.org/installer -o composer-setup.php
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

echo "--- Baixando e Instalando Composer ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--- Instalando Banco NoSQL -> Redis <- ---" 
sudo apt-get install redis-server --assume-yes
sudo apt-get install php7.2-redis --assume-yes
#sudo apt-get install php-redis --assume-yes

echo "--- Instalando Banco NoSQL -> Memcached <- ---" 
sudo apt-get install memcached --assume-yes
sudo apt-get install libmemcached-tools --assume-yes

echo "--- Instalando Banco NoSQL -> MongoDB <- ---"
#https://tecadmin.net/install-mongodb-on-ubuntu/ 
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get install mongodb-org --assume-yes
# sudo systmectl enable mongod
# sudo systmectl start mongod
# sudo systmectl stop mongod
# sudo systmectl restart mongod 

echo "--- Habilitando o PHP 7.2 ---"
sudo a2dismod php5 php7.0 php7.1
sudo a2enmod php7.2

echo "--- Habilitando mod-rewrite do Apache ---"
sudo a2enmod rewrite

echo "--- Reiniciando Apache ---"
sudo systemctl enable apache2
sudo service apache2 restart
sudo systemctl status apache.service

echo "--- Instalando NGINX ---"
sudo apt-get install nginx --assume-yes
sudo systemctl stop nginx
sudo rm /etc/nginx/sites-available/default

echo "server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name server_domain_name_or_IP;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}" >> /etc/nginx/sites-available/default

sudo systemctl disable nginx

echo "--- Baixando e Instalando NodeJS ---"
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
sudo apt-get install nodejs --assume-yes
sudo apt-get install build-essential --assume-yes

echo "--- Reiniciando Apache ---"
sudo systemctl enable apache2
sudo service apache2 reload
sudo service apache2 restart
sudo systemctl status apache.service

# Instale apartir daqui o que você desejar 

echo "--- Atualizando lista de pacotes ---"
sudo apt-get update

echo "[OK] --- Ambiente de desenvolvimento concluido ---"