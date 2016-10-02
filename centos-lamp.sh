#!/bin/bash

main() {
	echo "Install Linux, Apache, MySQL, PHP (LAMP) stack On CentOS 7"
	install_apache
	install_mysql
	install_php
	echo "Processing of LAMP is completed!"
}

install_apache() {
	echo "Install Apache and start the web service"
	yum install -y httpd >> /tmp/centos-lamp.log 2>&1
	systemctl start httpd.service >> /tmp/centos-lamp.log 2>&1
	systemctl enable httpd.service >> /tmp/centos-lamp.log 2>&1
}

install_mysql() {
	echo "Install MySQL (MariaDB) and start the database service"
	yum install -y mariadb-server mariadb >> /tmp/centos-lamp.log 2>&1
	systemctl start mariadb.service >> /tmp/centos-lamp.log 2>&1
	systemctl enable mariadb.service >> /tmp/centos-lamp.log 2>&1
	mysql_secure_installation <<EOF

y
db2016
db2016
y
y
y
y
EOF
}

install_php() {
	echo "Install PHP"
	yum install -y php php-pear php-mysql phpMyAdmin >> /tmp/centos-lamp.log 2>&1
	systemctl restart httpd.service >> /tmp/centos-lamp.log 2>&1
}

main
exit 0