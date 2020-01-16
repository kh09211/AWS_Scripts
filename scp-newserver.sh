#!/bin/bash
# This script will copy the starter files to an AWS instance
# neccessary to set up a webserver on the new device
echo 'SSH copy LEMP starter files to AWS server'
echo 'note: PEM file for instance must be in scripts folder'
echo 'Contents:' ;ls -l
echo 'Please enter the IP address of the new AWS instance:'
read ipAddy
echo 'Please enter the PEM filename if different than aws.pem otherwise hit enter:'
read pemFile
if [[ -z "$pemFile" ]]; then
	pemFile="aws.pem"
fi
echo 'copying files.....'
scp -i "${pemFile}" ./starter-files/* "ubuntu@${ipAddy}:~/"
echo 'done'
echo 'Would you like to begin an SSH connection to this server? (y/n)'
read yesNo
if [ "$yesNo" = "y" ]; then
ssh -i "${pemFile}" "ubuntu@${ipAddy}"
else
exit
fi
echo 'Would you like to begin another SSH connection to this server? (y/n)'
read yesNo
if [ "$yesNo" = "y" ]; then
ssh -i "${pemFile}" "ubuntu@${ipAddy}"
fi

