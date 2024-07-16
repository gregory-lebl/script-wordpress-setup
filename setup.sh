#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y mariadb-server apache2
sudo apt install -y libapache2-mod-php php-curl php-gd php-intl php-mbstring php-mysql php-soap php-xml php-xmlrpc php-zip
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress/ /var/www/
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod -R 755 /var/www/wordpress/
# TODO: Script to create user and database
sudo mariadb -pSeCrEt << EOF
create database wordpress default character set utf8 collate utf8_unicode_ci;
GRANT ALL privileges on wordpress.* to wordpress_user@localhost identified by 'wordpress';
flush privileges;
exit;
EOF
# TODO: import apache2 vhost for Wordpress
sudo touch /etc/apache2/sites-available/wordpress.conf
sudo echo "<VirtualHost *:80>
    DocumentRoot /var/www/wordpress
    <Directory /var/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /var/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" >> /etc/apache2/sites-available/wordpress.conf
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2