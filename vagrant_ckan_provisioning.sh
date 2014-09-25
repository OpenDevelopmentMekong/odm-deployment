#!/usr/bin/env bash

sudo apt-get update -qq
sudo apt-get install -y python-dev postgresql libpq-dev python-pip python-virtualenv git-core solr-jetty openjdk-6-jdk
mkdir -p ~/ckan/lib
sudo ln -s ~/ckan/lib /usr/lib/ckan
mkdir -p ~/ckan/etc
sudo ln -s ~/ckan/etc /etc/ckan
sudo mkdir -p /usr/lib/ckan/default
sudo chown `whoami` /usr/lib/ckan/default
virtualenv --no-site-packages /usr/lib/ckan/default
. /usr/lib/ckan/default/bin/activate

# Download CKAN 2.2 stable release
pip install -e "git+https://github.com/ckan/ckan.git@ckan-2.2#egg=ckan"
pip install -r /usr/lib/ckan/default/src/ckan/requirements.txt
deactivate
. /usr/lib/ckan/default/bin/activate

# Change the DB's encoding from LATIN-1 to UTF-8
postgresql LATIN_1 vs UTF-8
sudo -u postgres pg_dumpall > /tmp/postgres.sql
sudo pg_dropcluster --stop 9.1 main
sudo pg_createcluster --locale en_US.UTF-8 --start 9.1 main
sudo -u postgres psql -f /tmp/postgres.sql

# Pasting password into ~/.pgpass to bypass password prompt while running createuser for ckan_default
# TODO: Hide password
echo '*:*:*:ckan_default:odmadmin' >> ~/.pgpass
sudo -u postgres createuser --no-password -S -D -R ckan_default
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
sudo mkdir -p /etc/ckan/default
sudo chown -R `whoami` /etc/ckan/

# Dynamic editing of ini file could be an alternative for downloading raw files
#cd /usr/lib/ckan/default/src/ckan
#paster make-config ckan /etc/ckan/default/development.ini
#sed -i.bak '/^sqlalchemy.url=/s/=.*/=postgresql://ckan_default:ckan_default_pass@localhost/ckan_default/' /etc/ckan/default/development.ini
#sed -i.bak '/^ckan.site_id=/s/=.*/=default' /etc/ckan/default/development.ini

# Download raw config files from github: production.ini -> development.ini and jetty
cd /etc/ckan/default
sudo wget -O development.ini https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/production.ini?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9wcm9kdWN0aW9uLmluaSIsImV4cGlyZXMiOjE0MTIwODI5Mjd9--56af3fadc7cae1679558f04e9130aa28f0247231
cd /etc/default
sudo wget -O jetty https://raw.githubusercontent.com/OpenDevelopmentMekong/odm-scripting/deployment-scripts/deployment-scripts/jetty?token=384894__eyJzY29wZSI6IlJhd0Jsb2I6T3BlbkRldmVsb3BtZW50TWVrb25nL29kbS1zY3JpcHRpbmcvZGVwbG95bWVudC1zY3JpcHRzL2RlcGxveW1lbnQtc2NyaXB0cy9qZXR0eSIsImV4cGlyZXMiOjE0MTIwMzM5Nzl9--9f549c7fabc847cd33b284c060ebd80d32851f14

# Once the repo becomes public, instead of the lines above, we clone odm-scripting repo and copy config files to the path they belong: development.ini and jett
#mkdir -p /usr/lib/ckan/default/src/odm-scripting
#cd /usr/lib/ckan/default/src/odm-scripting
#git clone -b deployment-scripts https://github.com/OpenDevelopmentMekong/odm-scripting.git .
#cp -fr deployment-scripts/development.ini /etc/ckan/default
#cp -fr deployment-scripts/jetty /etc/default

sudo service jetty start
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service jetty restart
cd /usr/lib/ckan/default/src/ckan

# Init DB
paster --plugin=ckan db init -c /etc/ckan/default/development.ini
ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini

# Install ckanapi, needed by the ckanext-odm_utils plugin
pip install -e "git+https://github.com/ckan/ckanapi.git@ckanapi-3.3#egg=ckanapi"

# Clone ckanext-odm_utils
mkdir -p /usr/lib/ckan/default/src/ckanext-odm_utils
cd /usr/lib/ckan/default/src/ckanext-odm_utils/
git clone https://github.com/OpenDevelopmentMekong/ckanext-odm_utils.git .

# Clone ckanext-odm_theme
mkdir -p /usr/lib/ckan/default/src/ckanext-odm_theme
cd /usr/lib/ckan/default/src/ckanext-odm_theme/
git clone https://github.com/OpenDevelopmentMekong/ckanext-odm_theme.git .

# Install Datastore extension
# Pasting password into ~/.pgpass to bypass password prompt while running createuser for datastore_default
# TODO: Hide password
echo '*:*:*:datastore_default:odmadmin' >> ~/.pgpass
sudo -u postgres createuser --no-password -S -D -R datastore_default
sudo -u postgres createdb -O ckan_default datastore_default -E utf-8
sudo ckan datastore set-permissions postgres --config="/etc/ckan/default/development.ini"

# Install FileStore
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default

# OPTIONAL: Install Datapusher extension
sudo apt-get install python-dev python-virtualenv build-essential libxslt1-dev libxml2-dev git
sudo virtualenv /usr/lib/ckan/datapusher
sudo mkdir /usr/lib/ckan/datapusher/src
cd /usr/lib/ckan/datapusher/src
sudo git clone -b stable https://github.com/ckan/datapusher.git
cd datapusher
sudo /usr/lib/ckan/datapusher/bin/pip install -r requirements.txt
sudo /usr/lib/ckan/datapusher/bin/python setup.py develop
sudo cp deployment/datapusher /etc/apache2/sites-available/
sudo cp deployment/datapusher.wsgi /etc/ckan/
sudo cp deployment/datapusher_settings.py /etc/ckan/
sudo sh -c 'echo "NameVirtualHost *:8800" >> /etc/apache2/ports.conf'
sudo sh -c 'echo "Listen 8800" >> /etc/apache2/ports.conf'
sudo a2ensite datapusher

# Install ckanext-spatial extension (Just for Previer for spatial formats)
pip install -e "git+https://github.com/okfn/ckanext-spatial.git@stable#egg=ckanext-spatial"

# Install Google Analytics extension
pip install -e  "git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics"

# FINALLY, restart apache
sudo service apache2 restart
