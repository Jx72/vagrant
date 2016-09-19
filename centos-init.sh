#!/bin/bash

echo $HOSTNAME is initailizing the system...

echo Set the timezone to Australia/Sydney
timedatectl set-timezone Australia/Sydney

echo Update the CentOS 7 system...
yum update -y 

echo Add the CentOS 7 EPEL repository
yum install -y epel-release

