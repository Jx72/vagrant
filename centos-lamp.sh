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
	yum install -y httpd >& /tmp/centos-lamp.log 
	systemctl start httpd.service >& /tmp/centos-lamp.log 
	systemctl enable httpd.service >& /tmp/centos-lamp.log 
}

install_mysql() {
	echo "Install MySQL (MariaDB) and start the database service"
	yum install -y mariadb-server mariadb >& /tmp/centos-lamp.log 
	systemctl start mariadb.service >& /tmp/centos-lamp.log 
	systemctl enable mariadb.service >& /tmp/centos-lamp.log 

# 	mysql_secure_installation <<EOF
# 
# y
# db2016
# db2016
# y
# y
# y
# y
# EOF

	mysql -sfu root -e "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
	DELETE FROM mysql.user WHERE User='';
	DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
	DROP DATABASE IF EXISTS test;
	DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
	FLUSH PRIVILEGES;"
}

install_php() {
	echo "Install PHP"
	yum install -y php php-pear php-mysql phpMyAdmin >& /tmp/centos-lamp.log 
	systemctl restart httpd.service >& /tmp/centos-lamp.log 
}

main
exit 0