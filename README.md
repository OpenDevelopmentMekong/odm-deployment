scripting
=========

Repository to host utility scripts to add/migrate/update data in the different modules.

### Scripts to insert/import data into CKAN
* ckan-scripts/import_from_geoserver.py
* ckan-scripts/import_taxonomy_tag_dictionaries.py
* ckan-scripts/import_taxonomy_term_translations.py
* ckan-scripts/insert_initial_odm_data.py

### Config files for ckan deployment
* deployment-scripts/ckan_deployment/apache/apache.wsgi
* deployment-scripts/ckan_deployment/apache/ckan_default
* deployment-scripts/ckan_deployment/apache/ports.conf
* deployment-scripts/ckan_deployment/jetty/jetty
* deployment-scripts/ckan_deployment/nginx/ckan_default
* deployment-scripts/ckan_deployment/postgresql/pg_hba.conf
* deployment-scripts/ckan_deployment/development.ini
* deployment-scripts/ckan_deployment/production.ini

### Vagrantfile & bootstrap for setting up the development environment automatically
* vagrant/Vagrantfile
* vagrant/bootstrap.sh
* vagrant/wordpress.sh
* vagrant/config.cfg.sample
