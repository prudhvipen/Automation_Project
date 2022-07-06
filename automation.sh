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

cd
cd tmp
tar -zcvf ${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/access.log /var/log/apache2/error.log

#Copying the tar file into AWS s3 bucket
aws s3 cp ${myname}-httpd-logs-${timestamp}.tar $s3storage

#To check if the /var/www/html/inventory.html exists and creating if needed
if
[ -e /var/www/html/inventory.html ]
then
echo "inventory.html is found"
else
touch /var/www/html/inventory.html
fi


#To check if the header is present or to append if not present
file=/var/www/html/inventory.html
heading="LogType                TimeCreated             Type                    Size"

if grep -wo "LogType" $file 
then
echo "Header found"
else
echo    ${heading} >> $file
fi


#Appending the Tar archive entry
tarfile=${myname}-httpd-logs-${timestamp}.tar

LogType=httpd
TimeCreated=$timestamp
Type=tar
Size=$(ls -lh $tarfile | awk '{print  $5}')

newentry=${LogType}"		"${TimeCreated}"		"${Type}"		"${Size}K

echo $newentry>>$file


#to check if the cron.d directory exists and to create if it is not.
cd /etc/
dir="/etc/cron.d/"

if [ -d "$dir" ] 
then
echo "cron.d folder exists"
else
mkdir cron.d
fi

#Creating the cron automation file

if
[ -e automation ]
then
rm automation
else
exit
fi

#creating the cron schedule
touch  /etc/cron.d/automation
echo "* 12 * * * root  /root/Automation_Project/automation.sh" >> automation
chmod +x automation

