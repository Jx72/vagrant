#!/bin/bash

echo Install Linux, Apache, MySQL, PHP (LAMP) stack On CentOS 7

echo Install Apache and start the web service
yum install -y httpd 
systemctl start httpd.service && systemctl enable httpd.service 

echo Install MySQL (MariaDB) and start the database service
yum install -y mariadb-server mariadb 
systemctl start mariadb.service && systemctl enable mariadb.service 
mysql_secure_installation <<EOF

y
db2016
db2016
y
y
y
y
EOF

echo Install PHP
yum install -y php php-pear php-mysql phpMyAdmin 
systemctl restart httpd.service 

echo LAMP installation is COMPLETED!
