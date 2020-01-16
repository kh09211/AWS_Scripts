#!/bin/bash
# This script in sudo will setup wordpress and a server config on the ubuntu 18.04 AWS server with nginx

# This sets the path of the nginx server and the web server root dir
nginxServerPath="/etc/nginx"
webServerPath="/var/www"

# Gather some info and check before writing files
echo 'What is the name of the  new website? NOTE:If not hosting multiple domains, use "default"'
read websiteName
echo "${websiteName}: is this correct? (y/n)"
read yesNo
if [ "$yesNo" != "y" ]; then
  echo 'You typed n or another key. Exiting'; exit
fi
if [[ -d "${webServerPath}/$websiteName" || -a "${nginxServerPath}/sites-available/$websiteName" ]]; then
  echo 'WARNING: new website files already exist. Continue script? (y/n)'
  echo 'NOTE: if using default ignore and continue'
  read yesNo
  if [ "$yesNo" != "y" ]; then
    echo 'Exiting Script. Nothing Changed'; exit
  fi
fi

# configuration of new site
echo "${websiteName}: Create directories and config files for this site? (y/n/default)"
echo 'NOTE: If using default config (for non-virtual servers) type default here'
read yesNo
if [ "$yesNo" == "y" ]; then
#check that template exist and copy it to dest in neccesary
  if [[ ! -e "${nginxServerPath}/sites-available/template-config-for-sites" ]]; then
    if [[ -e "${HOME}/template-config-for-sites" ]]; then
      echo 'Copying template file to nginx server dir'
      cp "${HOME}/template-config-for-sites" "${nginxServerPath}/sites-available"
    else
    echo 'ERROR: Template file for nginx config not found in home'
    exit
    fi
  fi
elif [ "$yesNo" == "default" ]; then
  #check that template exist and copy it to dest in neccesary
  if [[ ! -e "${nginxServerPath}/sites-available/default-config-for-sites" ]]; then
    if [[ -e "${HOME}/default-config-for-sites" ]]; then
      echo 'Copying default config file to nginx server dir'
      cp "${HOME}/default-config-for-sites" "${nginxServerPath}/sites-available/default"
      # mv "${nginxServerPath}/sites-available/default-config-for-sites" "${nginxServerPath}/sites-available/default"
    else
    echo 'ERROR: Template file for default nginx config not found in home'
    exit
    fi
  fi
fi  
# configure virtual sites 
if [ "$yesNo" == "y"  ]; then
    echo 'Configuring new website...'
    # create new website directory and test page
    mkdir -p "${webServerPath}/${websiteName}/html"    
    echo "<h1>${websiteName}<h1>" > "${webServerPath}/${websiteName}/html/index.php"
    # change ownership and permissions
    chmod -R 755 "${webServerPath}/${websiteName}/html"
    chown -R www-data:www-data "${webServerPath}/${websiteName}/html"
    # create nginx site server config files
    # note: must have sample config file named template-config-for-sites in sites-available dir and inside file the var NEW_WEBSITE_NAME
    sed "s/NEW_WEBSITE_NAME/${websiteName}/g" "${nginxServerPath}/sites-available/template-config-for-sites" >"${nginxServerPath}/sites-available/${websiteName}"
    ln -s "${nginxServerPath}/sites-available/$websiteName" "${nginxServerPath}/sites-enabled/$websiteName"
    echo "Configured successfully!"
elif [ "$yesNo" == "default" ]; then
  rm "${webServerPath}/html/"*
  echo "<h1>${websiteName} php works<h1>" > "${webServerPath}/html/index.php"
  chmod -R 755 "${webServerPath}/html"
  chown -R www-data:www-data "${webServerPath}/html"
fi

#run certbot program - must be installed
echo "Install HTTPS certifications with certbot? (y/n)"
read yesNo
if [ "$yesNo" == "y" ]; then
  certbot
fi

#download and extract latest wordpress to the new sites directory
echo "${websiteName}: install latest wordpress on this site? (y/n/default)"
echo 'NOTE: select "y" for virtual servers. To install to default html folder use "default"'
read yesNo
if [ "$yesNo" == "y" ]; then
  echo 'Downloading and installing latest wordpress'
  wget -P "${webServerPath}/${websiteName}/html" https://wordpress.org/latest.tar.gz
  tar -xzvf "${webServerPath}/${websiteName}/html/latest.tar.gz" -C "${webServerPath}/${websiteName}/html/"
  mv "${webServerPath}/${websiteName}/html/wordpress/"* "${webServerPath}/${websiteName}/html/"
  rmdir "${webServerPath}/${websiteName}/html/wordpress"
  chown -R www-data:www-data "${webServerPath}/${websiteName}/html"
  echo 'Wordpress installed succssfully'
elif [ "$yesNo" == "default" ]; then
  echo 'Downloading and installing latest wordpress'
  wget -P "${webServerPath}/html" https://wordpress.org/latest.tar.gz
  tar -xzvf "${webServerPath}/html/latest.tar.gz" -C "${webServerPath}/html/"
  mv "${webServerPath}/html/wordpress/"* "${webServerPath}/html/"
  rmdir "${webServerPath}/html/wordpress"
  chown -R www-data:www-data "${webServerPath}/html"
  echo 'Wordpress installed succssfully to default html folder'  
fi

#add user and setup database for new site
echo "${websiteName}: Would you like to setup the MYSQL database for wordpress now?"
read yesNo
if [ "$yesNo" = "y" ]; then
  echo "${websiteName}: Name of MYSQL database?"
  read databaseName
  echo "${websiteName}: Name of MYSQL username?"
  read userName
  echo "${websiteName}: password for MYSQL username:${userName}?"
  read passWord
  echo 'retype password...' 
  read passWord2
  if [ "$passWord" != "$passWord2" ]; then
    echo 'Passwords do not match! Not making database!'
  else
    echo 'Creating MYSQL database...'

# MYSQL database creation here
    mysql -e "CREATE DATABASE $databaseName;"
    mysql -e "GRANT ALL PRIVILEGES ON ${databaseName}.* TO '${userName}'@'localhost' IDENTIFIED BY '${passWord2}';"
    mysql -e "FLUSH PRIVILEGES;"

    echo 'Create updated wp-config.php file now? (y/n)'
    read yesNo2
    if [ "$yesNo2" == "y" ];then
      sed -e "s/database_name_here/${databaseName}/" -e "s/username_here/${userName}/" -e "s/password_here/${passWord2}/" "${webServerPath}/${websiteName}/html/wp-config-sample.php" >"${webServerPath}/${websiteName}/html/wp-config.php"
      echo 'wp-config.php created. Please update the AUTH settings manually!'
    else
    echo '... not creating config file. Update manually.'
    fi
  fi
fi

#reboot the server to take new config
echo 'Would you like to reboot the server now? (y/n)'
read yesNo
if [ "$yesNo" == "y" ]; then
  nginx -t
  systemctl restart nginx
echo 'Server rebooted. Script Complete, Exiting!'; exit
fi
echo 'Exiting without server reboot. Script Complete!' 
