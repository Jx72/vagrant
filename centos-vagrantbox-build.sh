#!/usr/bin/env bash

os='centos'
version='7'
sub_version=`vagrant box list -i | grep centos/7 | sort -r | sed 's/)/ /' | gawk '{print $3}' | sed '2,$d'`
today=`date +%Y%m%d`

os_version="${os}${version}-${sub_version}-${today}"

echo "============================================================"
echo "Box generated on ${today}"
echo "Building box ${os}/${version} version: ${sub_version} ..."
echo "============================================================"

echo "============================================================"
echo "To check the updates to 'centos/7'"
vagrant box update
echo "============================================================"

echo "============================================================"
echo "To shutdown the current vagrant if exits"
vagrant destroy -f
echo "============================================================"

echo "============================================================"
echo "To start up the vagrant OS from Vagrantfile"
vagrant up >> /dev/null
echo "============================================================"

if test $(ls | grep "${os_version}.box") ; then
	echo "============================================================"
	echo "Remove the vagrant box ${os_version}.box"
	rm "${os_version}.box"
	echo "============================================================"
fi

echo "============================================================"
echo "Pack up the vagrant OS ${os_version}.box"
vagrant package --output "${os_version}.box"
echo "============================================================"

echo "============================================================"
echo "Shutdown the current vagrant OS"
vagrant destroy -f
echo "============================================================"

if test $(vagrant box list -i | grep "${os_version}") ; then
	echo "============================================================"
	echo "Remove the previous vagrant box with the same name ${os_version}"
	vagrant box remove $os_version
	vagrant box list
	echo "============================================================"
fi

echo "============================================================"
echo "Add ${os_version}.box to vagrant box list"
vagrant box add "${os_version}.box" --name "${os_version}"
vagrant box list
echo "============================================================"


