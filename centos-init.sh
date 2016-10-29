#!/bin/bash

main() {
	echo "$HOSTNAME is initailizing the system"
	add_repo
	update
	install_com_sw
	echo "centos-init is completed!"
}

add_repo() {
	echo "Add the EPEL repository"
	yum install -y epel-release >> /tmp/centos-init.log 2>&1
}

update() {
	echo "Update the CentOS 7 system..."
	yum update -y >> /tmp/centos-init.log 2>&1
}

install_com_sw() {
	echo "Install some common utilities"
	yum install -y tree
}

main
exit 0