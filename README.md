# AWS_Scripts
Scripts to setup nginx, php, mysql, and wordpress on a fresh AWS EC2 ubuntu 18.04 instance
1) move pem file to the same dir as the scp-newserver.sh script
2) Use scp-newserver.sh to copy the starter-files to the ip of the new instance
3) run lemp-install-aws.sh on the instance to setup the lemp server and config
4) when you exit then reurn into the server, run newsite.sh to configure the webserver and/or wordpress
5) test by logging into the IP or domain name
