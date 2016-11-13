#!/usr/bin/env bash

base_dir=$1
vhost_dev=$2
djg_prj_name=$3

www_dir=$base_dir/www
# html_dir=$www_dir/html
# phtml_dir=$www_dir/$vhost_dev/public_html
djg_vhost_dev=django.$vhost_dev
djg_prj_dir=$www_dir/$djg_vhost_dev/$djg_prj_name

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

echo "Install Web Server Gateway Interface(WSGI)"
yum install -y mod_wsgi >> /tmp/provision-script.log 2>&1

echo "Install Django through pip"
yum install -y python-pip >> /tmp/provision-script.log 2>&1
pip install --upgrade pip >> /tmp/provision-script.log 2>&1
pip install django >> /tmp/provision-script.log 2>&1
echo "Django Version: " && django-admin --version

logs_dir=$base_dir/logs/$djg_vhost_dev
mkdir -p $logs_dir

echo "Creating a Django Test Project"
mkdir -p $www_dir/$djg_vhost_dev
cd $www_dir/$djg_vhost_dev
django-admin startproject $djg_prj_name

# echo "Create a new database"
# mysql -u root -proot -e "CREATE DATABASE djangotestdb;"

# echo "Create a new MySQL user with a password"
# mysql -u root -proot -e "CREATE USER  'djangotestuser'@'localhost' IDENTIFIED BY 'password';"

# echo "Grant the new MySQL user permissions to manipulate the database"
# mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'djangotestuer'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;"

echo "To set Virtual Host"
echo "
<VirtualHost *:80>
    ServerName ${djg_vhost_dev}
    DocumentRoot ${djg_prj_dir}
    ErrorLog ${logs_dir}/error_log
    CustomLog ${logs_dir}/custom_log combined

    WSGIScriptAlias / ${djg_prj_dir}/${djg_prj_name}/wsgi.py

	<Directory \"${djg_prj_dir}/${djg_prj_name}/\">
	  <Files wsgi.py>
	    Require all granted
	  </Files>
	</Directory>
</VirtualHost>

WSGIPythonPath ${djg_prj_dir}/
" > /etc/httpd/sites-available/$djg_vhost_dev.conf

echo "To enable the New Virtual Host Files"
ln -s /etc/httpd/sites-available/$djg_vhost_dev.conf /etc/httpd/sites-enabled/$djg_vhost_dev.conf

chg_own_mod_sel $djg_prj_dir $logs_dir

apachectl restart