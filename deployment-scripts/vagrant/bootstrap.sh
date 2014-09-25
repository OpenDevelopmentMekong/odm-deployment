#!/usr/bin/env bash

echo 'Starting provisioning'
echo '----------------------------------'

sudo apt-get update -qq
sudo apt-get install --yes libpq5 python-dev postgresql libpq-dev python-pip python-virtualenv git-core solr-jetty openjdk-6-jdk
# mkdir -p ~/ckan/lib
# sudo ln -s ~/ckan/lib /usr/lib/ckan
# mkdir -p ~/ckan/etc
# sudo ln -s ~/ckan/etc /etc/ckan
sudo mkdir -p /usr/lib/ckan/default
sudo chown `whoami` /usr/lib/ckan/default
virtualenv --no-site-packages /usr/lib/ckan/default
. /usr/lib/ckan/default/bin/activate

echo 'Download CKAN 2.2 stable release'
echo '----------------------------------'
pip install -e "git+https://github.com/ckan/ckan.git@ckan-2.2#egg=ckan"
pip install -r /usr/lib/ckan/default/src/ckan/requirements.txt
deactivate
. /usr/lib/ckan/default/bin/activate

echo 'Change the DBs encoding from LATIN-1 to UTF-8'
echo '----------------------------------'
postgresql LATIN_1 vs UTF-8
sudo -u postgres pg_dumpall > /tmp/postgres.sql
sudo pg_dropcluster --stop 9.1 main
sudo pg_createcluster --locale en_US.UTF-8 --start 9.1 main
sudo -u postgres psql -f /tmp/postgres.sql

echo 'Pasting password into ~/.pgpass to bypass password prompt while running createuser for ckan_default'
echo '----------------------------------'
# TODO: Hide password
echo '*:*:*:*:odmadmin' > ~/.pgpass
#sudo -u postgres createuser --no-password -S -D -R ckan_default
sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
sudo mkdir -p /etc/ckan/default
sudo chown -R `whoami` /etc/ckan/

echo 'Download pg_hba.conf from odm-scripting repo to prevent FATAL: password authentication failed'
echo '----------------------------------'
cd /etc/postgresql/9.1/main/
sudo wget -O pg_hba.conf https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/pg_hba.conf?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvcGdfaGJhLmNvbmYiLCJleHBpcmVzIjoxNDEyMjA0NzE5fQ%3D%3D--320252a6480b3084a1ee47b3b56e074de56fec49
sudo service postgresql restart

# Dynamic editing of ini file could be an alternative for downloading raw files
#cd /usr/lib/ckan/default/src/ckan
#paster make-config ckan /etc/ckan/default/development.ini
#sed -i.bak '/^sqlalchemy.url=/s/=.*/=postgresql://ckan_default:ckan_default_pass@localhost/ckan_default/' /etc/ckan/default/development.ini
#sed -i.bak '/^ckan.site_id=/s/=.*/=default' /etc/ckan/default/development.ini

echo 'Download raw config files from github: development.ini and jetty'
echo '----------------------------------'
cd /etc/ckan/default
sudo wget -O development.ini https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/development.ini?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvZGV2ZWxvcG1lbnQuaW5pIiwiZXhwaXJlcyI6MTQxMjIxMjU5M30%3D--10a19f361d0ffd81eee0570eae6f252cef5f2df5
cd /etc/default
sudo wget -O jetty https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/jetty?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvamV0dHkiLCJleHBpcmVzIjoxNDEyMTcwMTMwfQ%3D%3D--18b9c4caa2e60fb2ffac45c0285c309d79f95483

# Once the repo becomes public, instead of the lines above, we clone odm-scripting repo and copy config files to the path they belong: development.ini and jett
#mkdir -p /usr/lib/ckan/default/src/odm-scripting
#cd /usr/lib/ckan/default/src/odm-scripting
#git clone -b deployment-scripts https://github.com/OpenDevelopmentMekong/odm-scripting.git .
#cp -fr deployment-scripts/development.ini /etc/ckan/default
#cp -fr deployment-scripts/jetty /etc/default

echo 'Start Jetty, link Solr schema.xml'
echo '----------------------------------'
sudo service jetty start
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service jetty restart
cd /usr/lib/ckan/default/src/ckan

echo 'Install ckanapi, needed by the ckanext-odm_utils plugin'
echo '----------------------------------'
sudo pip install -e "git+https://github.com/ckan/ckanapi.git@ckanapi-3.3#egg=ckanapi"

echo 'Clone ckanext-odm_utils'
echo '----------------------------------'
mkdir -p /usr/lib/ckan/default/src/ckanext-odm_utils
cd /usr/lib/ckan/default/src/ckanext-odm_utils/
git clone https://github.com/OpenDevelopmentMekong/ckanext-odm_utils.git .
sudo python setup.py develop

echo 'Clone ckanext-odm_theme'
echo '----------------------------------'
mkdir -p /usr/lib/ckan/default/src/ckanext-odm_theme
cd /usr/lib/ckan/default/src/ckanext-odm_theme/
git clone https://github.com/OpenDevelopmentMekong/ckanext-odm_theme.git .
sudo python setup.py develop

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install FileStore'
echo '----------------------------------'
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install ckanext-spatial extension (Just for Preview for spatial formats)'
echo '----------------------------------'
sudo pip install -e "git+https://github.com/okfn/ckanext-spatial.git@stable#egg=ckanext-spatial"
sudo pip install -r pip-requirements.txt

# go back to ckan dir
cd /usr/lib/ckan/default/

# echo 'Install Google Analytics extension'
# echo '----------------------------------'
# sudo pip install -e  "git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics"
# cd /usr/lib/ckan/default/src/ckanext-googleanalytics
# sudo python setup.py develop

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install Pages extension'
echo '----------------------------------'
sudo pip install -e 'git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages'
cd /usr/lib/ckan/default/src/ckanext-pages
sudo python setup.py develop

echo 'Install Datastore extension'
echo '----------------------------------'
# Pasting password into ~/.pgpass to bypass password prompt while running createuser for datastore_default
# TODO: Hide password
#echo '*:*:*:datastore_default:odmadmin' >> ~/.pgpass
#sudo -u postgres createuser --no-password -S -D -R datastore_default
sudo -u postgres createuser -S -D -R datastore_default
sudo -u postgres createdb -O ckan_default datastore_default -E utf-8
sudo /usr/lib/ckan/default/bin/paster --plugin=ckan datastore set-permissions postgres --config="/etc/ckan/default/development.ini"

echo 'Init DB, after instaling plugins'
echo '----------------------------------'
sudo /usr/lib/ckan/default/bin/paster --plugin=ckan db init --config=/etc/ckan/default/development.ini
ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini

echo 'Deployment: Following this http://docs.ckan.org/en/latest/maintaining/installing/deployment.html'
echo '----------------------------------'
cp /etc/ckan/default/development.ini /etc/ckan/default/production.ini
sudo apt-get install -y apache2 libapache2-mod-wsgi
sudo apt-get install -y nginx
# sudo apt-get install -y postfix -> This breaks the script!!

echo 'Download WSGI script file from odm-scripting repo'
echo '----------------------------------'
cd /etc/ckan/default
sudo wget -O apache.wsgi https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/apache.wsgi?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvYXBhY2hlLndzZ2kiLCJleHBpcmVzIjoxNDEyMTcwMTc1fQ%3D%3D--81b94d1be2f976a730b3093e976050ce432d0f20

echo 'Download the Apache config file'
echo '----------------------------------'
cd /etc/apache2/sites-available/
sudo wget -O ckan_default https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/apache_ckan_default?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvYXBhY2hlX2NrYW5fZGVmYXVsdCIsImV4cGlyZXMiOjE0MTIxNzAyMDV9--59cfc8fef78d9cc9bf394cd1efe3f7cb46b1f91d

echo 'Download the Apache ports.conf file'
echo '----------------------------------'
cd /etc/apache2/
sudo wget -O ports.conf https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/ports.conf?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvcG9ydHMuY29uZiIsImV4cGlyZXMiOjE0MTIxNzAyMzB9--3aca22a0220234053e0350a0eb95b046a39e7a93

echo 'Download the Nginx config file'
echo '----------------------------------'
cd /etc/nginx/sites-available/
sudo wget -O ckan_default https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/ckan_deployment/nginx_ckan_default?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9ja2FuX2RlcGxveW1lbnQvbmdpbnhfY2thbl9kZWZhdWx0IiwiZXhwaXJlcyI6MTQxMjE3MDI0NH0%3D--8fac2687d2095ce2bade08540060f0f7dd476b06

echo 'Enable CKAN site'
echo '----------------------------------'
sudo a2ensite ckan_default
sudo ln -s /etc/nginx/sites-available/ckan_default /etc/nginx/sites-enabled/ckan_default

# echo 'OPTIONAL: Install Datapusher extension'
# echo '----------------------------------'
# sudo apt-get install python-dev python-virtualenv build-essential libxslt1-dev libxml2-dev git
# sudo virtualenv /usr/lib/ckan/datapusher
# sudo mkdir /usr/lib/ckan/datapusher/src
# cd /usr/lib/ckan/datapusher/src
# sudo git clone -b stable https://github.com/ckan/datapusher.git
# cd datapusher
# sudo /usr/lib/ckan/datapusher/bin/pip install -r requirements.txt
# sudo /usr/lib/ckan/datapusher/bin/python setup.py develop
# sudo cp deployment/datapusher /etc/apache2/sites-available/
# sudo cp deployment/datapusher.wsgi /etc/ckan/
# sudo cp deployment/datapusher_settings.py /etc/ckan/
# sudo sh -c 'echo "NameVirtualHost *:8800" >> /etc/apache2/ports.conf'
# sudo sh -c 'echo "Listen 8800" >> /etc/apache2/ports.conf'
# sudo a2ensite datapusher

echo 'FINALLY, restart apache and nginx'
echo '----------------------------------'
sudo service apache2 reload
sudo service nginx reload
