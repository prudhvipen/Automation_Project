#!/bin/bash
#!/usr/bin/sudo bash
#!/usr/bin/env bash

s3storage=s3://upgrad-prudhvi
myname=Prudhvi

#update the packages at start
sudo apt update -y

#To check whether the apache is installed
if
dpkg --get-selections | grep apache
then
echo "Apache2 is installed"
else sudo apt install apache2
fi

#To check whether the service is enabled and to restart
if
sudo service apache2 status
then
echo "The service is enabled"
else
sudo service apache2 restart
fi

#making tar file of /var/log/apache2 log files
timestamp=$(date '+%d%m%Y-%H%M%S')

cd /home/ubuntu/tmp/
tar -zcvf ${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/access.log /var/log/apache2/error.log

#Copying the tar file into AWS s3 bucket
aws s3 cp ${myname}-httpd-logs-${timestamp}.tar $s3storage
