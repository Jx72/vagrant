#!/bin/bash

echo Create the web example for Apache test

echo Allow everyone to read and execute files and directories recursively
chmod -R 755 /var/www

echo Create directories sites-available and sites-enabled in /etc/httpd
mkdir /etc/httpd/sites-available
mkdir /etc/httpd/sites-enabled

echo Customize the directory structure for web server @ /var/www/example.com
mkdir -p /var/www/example.com/public_html

echo Grant Permissions to $USERNAME
chown -R $USERNAME:$USERNAME /var/www/example.com/public_html

echo Create PHP info test page; please remove it after test
echo "
<?php phpinfo(); ?>
" > /var/www/example.com/public_html/info.php

echo Create Demo Page for the Virtual Host
echo "Welcome to Example.com" >>/var/www/example.com/public_html/index.html

echo Include enable Virtual Host Configration Files
echo "IncludeOptional sites-enabled/*.conf" >>/etc/httpd/conf/httpd.conf

echo Create the Virtual Host File
echo "
<VirtualHost *:80>
    ServerName www.example.com
    ServerAlias example.com
    DocumentRoot /var/www/example.com/public_html
</VirtualHost>
" >> /etc/httpd/sites-available/example.com.conf

echo Enable the New Virtual Host Files
ln -s /etc/httpd/sites-available/example.com.conf /etc/httpd/sites-enabled/example.com.conf
apachectl restart

echo Web Example is CREATED!