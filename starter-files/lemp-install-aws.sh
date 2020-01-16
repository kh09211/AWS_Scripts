#!/bin/bash
# This script installs the necesary basic packages on AWS 18.04 server to run a LEMP webserver
# run as sudo
groupList=$(groups ubuntu |grep -c 'www-data')
apt-get -y update
apt-get -y upgrade
echo 'Install NGINX, php, mariadb, and python? (y/n)'
read yesNo
if [ "$yesNo" = "y" ]; then
    apt-get -y install nginx php-fpm mariadb-server mariadb-client python
    echo 'NGINX, php-fpm, mariadb, and python installed!'
fi
echo 'Install neccessary php packages to run a wordpress a install? (y/n)'
read yesNo
if [ "$yesNo" = "y" ]; then
    apt-get -y install php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml libapache2-mod-php
fi
if [[ "$groupList" = "0" ]]; then
    echo 'You are not listed as a member of www-group. Add? (y/n)'
    read yesNo
    if [ "$yesNo" = "y" ]; then
        usermod -a -G www-data ubuntu
        echo 'You have been added to group:www-group. Please log-out and log-in before running any additonal scripts' 
   	echo 'Use "exit" to disconnect. If using the SCF script please log back in with "y"'
    else
    echo 'Not added to group www-data. Additional configuration may be affected. Script Complete!'
    fi
fi
echo 'LEMP script complete'
