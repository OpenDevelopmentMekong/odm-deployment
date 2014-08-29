#!/usr/bin/env bash

sudo apt-get update

sudo apt-get install -y nginx apache2 libapache2-mod-wsgi libpq5

wget http://packaging.ckan.org/python-ckan_2.2_amd64.deb

sudo dpkg -i python-ckan_2.2_amd64.deb

sudo apt-get install -y postgresql solr-jetty

/etc/default/jetty
NO_START=0            # (line 4)
JETTY_HOST=127.0.0.1  # (line 15)
JETTY_PORT=8983       # (line 18)

sudo service jetty start

Could not start Jetty servlet engine because no Java Development Kit (JDK) was found.
/etc/default/jetty
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/

sudo service jetty start

sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml

sudo service jetty restart

postgresql LATIN_1 vs UTF-8
sudo -u postgres pg_dumpall > /tmp/postgres.sql
sudo pg_dropcluster --stop 9.1 main
sudo pg_createcluster --locale en_US.UTF-8 --start 9.1 main
sudo -u postgres psql -f /tmp/postgres.sql

production.ini
sqlalchemy.url = postgresql://ckan_default:pass@localhost/ckan_default


Spatial Extension

sudo apt-get install postgresql-9.1-postgis