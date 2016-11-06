#!/bin/bash

base_dir=$1
vhost_dev=$2

www_dir=$base_dir/www

main() {
	echo "Install Linux, Apache, MySQL, PHP (LAMP) stack On CentOS 7"
	ist_apache
	ist_mysql
	ist_php
	crt_html_test
	crt_php_test
	echo "Processing of LAMP is completed!"
}

ist_apache() {
	echo "Install Apache and start the web service"
	yum install -y httpd >& /tmp/centos-lamp.log 

	systemctl start httpd.service >& /tmp/centos-lamp.log 
	systemctl enable httpd.service >& /tmp/centos-lamp.log 

	# echo "To set Apache (HTTPD) configration"
	# echo "To modify /etc/httpd/conf/httpd.conf"
	# mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
	# bash -c "sed -e 's#\"/var/www\"#\"'$www_dir'\"#' -e 's#\"/var/www/html\"#\"'$www_dir'/html\"#' </etc/httpd/conf/httpd.conf.old >/etc/httpd/conf/httpd.conf"

	echo "To create directories for sites configration"
	mkdir /etc/httpd/sites-available
	mkdir /etc/httpd/sites-enabled

	bash -c 'echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf'

	systemctl restart httpd.service	
}

ist_mysql() {
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

ist_php() {
	echo "Install PHP"
	yum install -y php php-pear php-mysql phpMyAdmin >& /tmp/centos-lamp.log 
	systemctl restart httpd.service >& /tmp/centos-lamp.log 
}

chg_own_mod_sel() {
	if [ $# -ge 1 ]; then
		doc_root=$1

		# Ownership
		chown apache:apache -R $doc_root

		cd $doc_root
	 
		# File permissions, recursive
		find . -type f -exec chmod 0644 {} \;
		 
		# Dir permissions, recursive
		find . -type d -exec chmod 0755 {} \;
		 
		# SELinux serve files off Apache, resursive
		chcon -t httpd_sys_content_t $doc_root -R

	fi

	# Allow write only to specific dirs
	if [ $# -ge 2 ]; then
		err_log=$2
		chcon -t httpd_sys_rw_content_t $err_log -R
	fi

	if [ $# -eq 3 ]; then
		cust_log=$3
		chcon -t httpd_sys_rw_content_t $cust_log -R	
	fi
}

crt_html_test() {
	html_vhost_dev=html.$vhost_dev

	htdocs_dir=$www_dir/$html_vhost_dev/htdocs
	mkdir -p $htdocs_dir

	logs_dir=$base_dir/logs/$html_vhost_dev
	mkdir -p $logs_dir

	echo "To create a demo of HTML page"
	echo "Welcome to HTML page" > $htdocs_dir/index.html

	echo "To set Virtual Host"
	echo "
<VirtualHost *:80>
    ServerName ${html_vhost_dev}
    DocumentRoot ${htdocs_dir}
    ErrorLog ${logs_dir}/error_log
    CustomLog ${logs_dir}/custom_log combined

    <Directory \"${htdocs_dir}\">
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
	" > /etc/httpd/sites-available/$html_vhost_dev.conf

	echo "To enable the New Virtual Host Files"
	ln -s /etc/httpd/sites-available/$html_vhost_dev.conf /etc/httpd/sites-enabled/$html_vhost_dev.conf

	chg_own_mod_sel $htdocs_dir $logs_dir

	apachectl restart
}

crt_php_test() {
	php_vhost_dev=php.$vhost_dev

	php_dir=$www_dir/$php_vhost_dev/php
	mkdir -p $php_dir

	logs_dir=$base_dir/logs/$php_vhost_dev
	mkdir -r $logs_dir

	echo "To create PHP info test page"
	echo "<?php phpinfo(); ?>" > $php_dir/default.php

	echo "To set Virtual Host"
	echo "
<VirtualHost *:80>
    ServerName ${php_vhost_dev}
    DocumentRoot ${php_dir}
    ErrorLog ${logs_dir}/error_log
    CustomLog ${logs_dir}/custom_log combined

    <Directory \"${php_dir}\">
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
	" >> /etc/httpd/sites-available/$php_vhost_dev.conf

	echo "To enable the New Virtual Host Files"
	ln -s /etc/httpd/sites-available/$php_vhost_dev.conf /etc/httpd/sites-enabled/$php_vhost_dev.conf

	chg_own_mod_sel $php_dir $logs_dir

	apachectl restart	
}


main
exit 0