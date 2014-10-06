#!/usr/bin/env bash

echo 'Starting Wordpress provisioning, updating Ubuntu packages repo'
echo '----------------------------------'
sudo apt-get update -qq

echo 'Checking whether the config file is there'
echo '----------------------------------'

if [ ! -f /vagrant/config.cfg ]
then
  echo 'config.cfg file not found!!!! Please make sure you have created it.'
  exit 0
fi

source /vagrant/config.cfg

echo 'Cloning odm-scripting repo.'
echo '----------------------------------'
sudo apt-get install --yes git-core
cd /vagrant/
rm -rf odm-scripting
git clone -b odm-scripting-0.3 https://$github_user:$github_pass@github.com/OpenDevelopmentMekong/odm-scripting.git

echo 'Install apache/nginx, if not yet installed'
echo '----------------------------------'
sudo apt-get install --yes apache2 libapache2-mod-wsgi nginx

echo 'Install mysql server'
echo '----------------------------------'
echo 'mysql-server mysql-server/root_password password odmadmin' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password odmadmin' | sudo debconf-set-selections
sudo apt-get install --yes mysql-server

echo 'Install PHP'
echo '----------------------------------'
sudo apt-get install --yes php5 php5-mysql

echo 'Install WP-CLI, http://wp-cli.org'
echo '----------------------------------'
mkdir /vagrant/wp-cli
cd /vagrant/wp-cli/
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
sudo chown vagrant:vagrant /usr/local/bin/wp
# wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash
# echo "source /vagrant/wp-cli/wp-completion.bash" >> /home/vagrant/.bash_profile

echo 'Download WP version 4.0'
echo '----------------------------------'
sudo mkdir /var/www/wp
cd /var/www/wp/
wp core download --version=4.0 --allow-root
sudo chown -R vagrant:vagrant /var/www/wp

echo 'copy wp-config.php file from odm-scripting'
echo '----------------------------------'
cp -fr /vagrant/odm-scripting/deployment-scripts/wp_deployment/wp-config.php /var/www/wp/wp-config.php
sudo chown -R vagrant:vagrant /var/www/wp/wp-config.php

echo 'copy apache2/sites-available/wp from odm-scripting'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/wp_deployment/apache/wp /etc/apache2/sites-available/wp
sudo ln -s /etc/apache2/sites-available/wp /etc/apache2/sites-enabled

echo 'copy nginx/sites-available/wp from odm-scripting'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/wp_deployment/nginx/wp /etc/nginx/sites-available/wp
sudo ln -s /etc/nginx/sites-available/wp /etc/nginx/sites-enabled

echo 'Add virtual host on port 8081'
echo '----------------------------------'
sudo echo "NameVirtualHost *:8081" >> /etc/apache2/ports.conf
sudo echo "Listen 8081" >> /etc/apache2/ports.conf

echo 'Create WP DB'
echo '----------------------------------'
cd /var/www/wp/
wp db create --allow-root
sudo chown -R vagrant:vagrant /var/www/wp

echo 'Restart apache and nginx'
echo '----------------------------------'
sudo service apache2 reload
# sudo service nginx reload
