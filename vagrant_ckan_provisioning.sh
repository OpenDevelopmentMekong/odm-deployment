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

sudo ckan db init

Setting up the DataStore
------------------------

production.ini
ckan.plugins = datastore

postgres createuser -S -D -R -P -l datastore_default
sudo -u postgres createdb -O ckan_default datastore_default -E utf-8

ckan.datastore.write_url = postgresql://ckan_default:pass@localhost/datastore_default
ckan.datastore.read_url = postgresql://datastore_default:pass@localhost/datastore_default

sudo ckan datastore set-permissions postgres --config="/etc/ckan/default/production.ini"         
Set permissions for read-only user: SUCCESS

DataPusher - Automatically add Data to the CKAN DataStore
---------------------------------------------------------

sudo apt-get install python-dev python-virtualenv build-essential libxslt1-dev libxml2-dev git
git clone https://github.com/ckan/datapusher
cd datapusher

Data Viewer
----------

ckan.plugins += recline_view text_view pdf_view resource_proxy

Spatial Extension
-------------

sudo apt-get install postgresql-9.1-postgis

sudo -u postgres psql -d ckan_default -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
sudo -u postgres psql -d ckan_default -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql

sudo -u postgres psql

postgres=# \c ckan_default

ALTER TABLE spatial_ref_sys OWNER TO ckan_default;
ALTER TABLE geometry_columns OWNER TO ckan_default;

sudo apt-get install python-dev libxml2-dev libxslt1-dev libgeos-c1

sudo pip install -e "git+https://github.com/okfn/ckanext-spatial.git@stable#egg=ckanext-spatial"