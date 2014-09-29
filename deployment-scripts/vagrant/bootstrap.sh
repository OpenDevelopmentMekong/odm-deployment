#!/usr/bin/env bash

echo 'Starting provisioning, updating Ubuntu packages repo'
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
git clone -b odm-scripting-0.1.1 https://$github_user:$github_pass@github.com/OpenDevelopmentMekong/odm-scripting.git

echo 'CKAN Basic installation'
echo '----------------------------------'
sudo apt-get install --yes libpq5 python-dev postgresql libpq-dev python-pip python-virtualenv git-core solr-jetty openjdk-6-jdk

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
sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8

echo 'Copy pg_hba.conf from odm-scripting to prevent FATAL: password authentication failed'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/postgresql/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
sudo service postgresql restart

echo 'Create a CKAN config file, we actually download it'
echo '----------------------------------'
sudo mkdir -p /etc/ckan/default
sudo chown -R `whoami` /etc/ckan/

echo 'Copy development.ini from odm-scripting, instead of creating it using paster make-config'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/development.ini /etc/ckan/default/development.ini

echo 'Copy jetty config files from odm-scripting'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/jetty/jetty /etc/default/jetty

echo 'Start Jetty, link Solr schema.xml'
echo '----------------------------------'
sudo service jetty start
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service jetty restart

echo 'Create database tables'
echo '----------------------------------'
sudo /usr/lib/ckan/default/bin/paster --plugin=ckan db init --config=/etc/ckan/default/development.ini

echo 'Link to who.ini'
echo '----------------------------------'
ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini

echo 'Installing own extensions'
echo '----------------------------------'

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install ckanapi, needed by the ckanext-odm_utils plugin'
echo '----------------------------------'
pip install -e "git+https://github.com/ckan/ckanapi.git@ckanapi-3.3#egg=ckanapi"
cd /usr/lib/ckan/default/src/ckanapi
python setup.py develop

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Clone and install ckanext-odm_utils'
echo '----------------------------------'
mkdir -p /usr/lib/ckan/default/src/ckanext-odm_utils
cd /usr/lib/ckan/default/src/ckanext-odm_utils/
git clone https://github.com/OpenDevelopmentMekong/ckanext-odm_utils.git .
python setup.py develop

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Clone and install ckanext-odm_theme'
echo '----------------------------------'
mkdir -p /usr/lib/ckan/default/src/ckanext-odm_theme
cd /usr/lib/ckan/default/src/ckanext-odm_theme/
git clone https://github.com/OpenDevelopmentMekong/ckanext-odm_theme.git .
python setup.py develop

echo 'Installing other extensions'
echo '----------------------------------'

# Install extra packages: libxml2-dev and libxslt-dev are needed by ckanext-spatial, apache2/nginx for deployment
sudo apt-get install --yes libxml2-dev libxslt-dev
sudo apt-get install --yes apache2 libapache2-mod-wsgi
sudo apt-get install --yes nginx
# sudo apt-get install -y postfix -> This breaks the script!!

echo 'Install FileStore'
echo '----------------------------------'
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default

echo 'OPTIONAL: Install Datapusher extension'
echo '----------------------------------'
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

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install Pages extension'
echo '----------------------------------'
sudo pip install -e 'git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages'
cd /usr/lib/ckan/default/src/ckanext-pages
python setup.py develop

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install ckanext-spatial extension (Just for Preview for spatial formats)'
echo '----------------------------------'
sudo pip install -e "git+https://github.com/okfn/ckanext-spatial.git@stable#egg=ckanext-spatial"
cd /usr/lib/ckan/default/src/ckanext-spatial/
sudo pip install -r pip-requirements.txt
sudo python setup.py develop

# go back to ckan dir
cd /usr/lib/ckan/default/

echo 'Install Google Analytics extension'
echo '----------------------------------'
sudo pip install -e  "git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics"
cd /usr/lib/ckan/default/src/ckanext-googleanalytics
sudo python setup.py develop

echo 'Deployment: Following this http://docs.ckan.org/en/latest/maintaining/installing/deployment.html'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/production.ini /etc/ckan/default/production.ini

echo 'Set up the DataStore'
echo '----------------------------------'
# Pasting password into ~/.pgpass to bypass password prompt while running createuser for datastore_default
# TODO: Hide password
#echo '*:*:*:datastore_default:odmadmin' >> ~/.pgpass
#sudo -u postgres createuser --no-password -S -D -R datastore_default
sudo -u postgres createuser -S -D -R datastore_default
sudo -u postgres createdb -O ckan_default datastore_default -E utf-8
sudo /usr/lib/ckan/default/bin/paster --plugin=ckan datastore set-permissions postgres --config=/etc/ckan/default/production.ini

echo 'Download WSGI script file from odm-scripting repo'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/apache/apache.wsgi /etc/ckan/default/apache.wsgi

echo 'Download the Apache config file'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/apache/ckan_default /etc/apache2/sites-available/ckan_default

echo 'Download the Apache ports.conf file'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/apache/ports.conf /etc/apache2/ports.conf

echo 'Download the Nginx config file'
echo '----------------------------------'
sudo cp -fr /vagrant/odm-scripting/deployment-scripts/ckan_deployment/nginx/ckan_default /etc/nginx/sites-available/ckan_default

echo 'Enable CKAN site'
echo '----------------------------------'
sudo a2ensite ckan_default
sudo ln -s /etc/nginx/sites-available/ckan_default /etc/nginx/sites-enabled/ckan_default

echo 'Disable apache default site'
echo '----------------------------------'
sudo a2dissite default

echo 'Restart apache and nginx'
echo '----------------------------------'
sudo service apache2 reload
sudo service nginx reload

echo 'Configure Test environment'
echo '----------------------------------'
pip install -r /usr/lib/ckan/default/src/ckan/dev-requirements.txt
sudo -u postgres createdb -O ckan_default ckan_test -E utf-8
sudo -u postgres createdb -O ckan_default datastore_test -E utf-8
sudo /usr/lib/ckan/default/bin/paster --plugin=ckan datastore set-permissions postgres -c /usr/lib/ckan/default/src/ckan/test-core.ini

echo 'Configure NFS mountpoint to access for development'
echo '----------------------------------'
sudo apt-get install --yes nfs-common
sudo apt-get install --yes nfs-kernel-server
sudo echo '/usr/lib/ckan *(rw,async,no_subtree_check,insecure,anonuid=0,anongid=0,all_squash)' | sudo tee -a /etc/exports
sudo /etc/init.d/nfs-kernel-server restart

echo 'Create CKAN test data'
echo '----------------------------------'
sudo /usr/lib/ckan/default/bin/paster --plugin=ckan create-test-data -c /etc/ckan/default/production.ini

