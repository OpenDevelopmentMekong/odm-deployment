# TODO: find way of adding ports automatically.

# Install Jetty
# Create custom App called ckan_jetty (listening on port)
# note port number (which is 15899)



# cd /home/opendevmk/webapps/ckan_jetty
# wget -O jetty-distribution.tar.gz http://ftp.yz.yamagata-u.ac.jp/pub/eclipse//jetty/stable-8/dist/jetty-distribution-8.1.16.v20140903.tar.gz
# gzip -d jetty-distribution-8.1.16.v20140903.tar
# gtar xvf jetty-distribution-8.1.16.v20140903.tar  --strip-components=1
# rm jetty-distribution-8.1.16.v20140903.tar
# java -jar start.jar jetty.port=15899 &

mkdir ~/src

# Install Tomcat
# http://sangatpedas.com/20121125/how-to-install-tomcat-on-webfaction-tutorial/
# https://bitbucket.org/kboi/webfaction-tomcat-installer/src
# http://sangatpedas.com/20121127/how-to-install-solr-on-webfaction-tutorial/
# Create a custom app called ckan_tomcat (listening on port)
# port 25879
#
#
cd /home/opendevmk/webapps/ckan_tomcat
wget http://mirror.issp.co.th/apache/tomcat/tomcat-7/v7.0.55/bin/apache-tomcat-7.0.55.tar.gz
gtar xvf apache-tomcat-7.0.55.tar.gz --strip-components=1
rm apache-tomcat-7.0.55.tar.gz
# Git repository added to /home/opendevmk/repos/tomcat make sure to checkout all the configuration files for this purpose.
# This includes port number and default admin user



easy_install-2.7 virtualenv
 
easy_install-2.7 pip
pip2.7 install virtualenvwrapper
 
mkvirtualenv ckan --no-site-packages --distribute
workon ckan
 
mkdir -p ~/ckan/lib
mkdir -p ~/ckan/etc
 
# Problem with 2.2.1 https://github.com/ckan/ckan/pull/291
# pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.2#egg=ckan'

echo export WORKON_HOME=$HOME/.virtualenvs >> ~/.bash_profile
echo export VIRTUALENVWRAPPER_TMPDIR=$HOME/.virtualenvs/tmp >> ~/.bash_profile
echo export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2.7 >> ~/.bash_profile
echo source $HOME/bin/virtualenvwrapper.sh >> ~/.bash_profile
echo export PIP_VIRTUALENV_BASE=$WORKON_HOME >> ~/.bash_profile
echo export PIP_RESPECT_VIRTUALENV=true >> ~/.bash_profile

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_TMPDIR=$HOME/.virtualenvs/tmp
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2.7
source $HOME/bin/virtualenvwrapper.sh
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
 
mkdir -p /home/opendevmk/.virtualenvs/ckan/src

cd /home/opendevmk/.virtualenvs/ckan/src
 
git clone https://github.com/ckan/ckan.git
 
cd /home/opendevmk/.virtualenvs/ckan/src/ckan
 
git checkout -b ckan-2.2
 
curl https://github.com/ckan/ckan/commit/fa60dc947eb6db612218d8d89affec7d6df3b096.patch | patch -p1
 
pip install -e .
 
pip install -r requirements.txt

deactivate

## CREATE DATABASE
# dbname / username: ckan_default
# test password ckan_test1

#install solr
#folowing instructions from https://wiki.apache.org/solr/SolrTomcat
#
cd /home/opendevmk/webapps/ckan_tomcat
wget http://apache.spinellicreations.com/lucene/solr/4.7.2/solr-4.7.2.tgz
tar -zvxf solr-4.7.2.tgz
rm solr-4.7.2.tgz

cp -R /home/opendevmk/webapps/ckan_tomcat/solr-4.7.2/example/solr .

cp /home/opendevmk/.virtualenvs/ckan/src/ckan/ckan/config/solr/schema.xml /home/opendevmk/webapps/ckan_tomcat/solr/collection1/conf
cd /home/opendevmk/webapps/ckan_tomcat/solr/
cp /home/opendevmk/webapps/ckan_tomcat/solr-4.7.2/dist/solr-4.7.2.war /home/opendevmk/webapps/ckan_tomcat/solr/solr.war
cp /home/opendevmk/webapps/ckan_tomcat/solr-4.7.2/example/lib/ext/* /home/opendevmk/webapps/ckan_tomcat/lib
mkdir data
cd /home/opendevmk/repos/tomcat
git archive master | tar -x -C /home/opendevmk/webapps/ckan_tomcat

#TODO: add APR Library
#TODO make sure all functionality in https://bitbucket.org/kboi/webfaction-tomcat-installer/src replicated

# Init CKAN
# CKAN custom ap added to port 29043

cd /home/opendevmk/repos/ckan
git archive master | tar -x -C /home/opendevmk/ckan
cd ~/ckan/
paster --plugin=ckan db init --config=/home/opendevmk/ckan/etc/development.ini
ln -s $HOME/.virtualenvs/ckan/src/ckan/who.ini $HOME/ckan/etc/who.ini


# Install DataPusher https://github.com/ngds/ckanext-ngds/wiki/2.-Setting-Up-CKAN:-Installing-the-DataPusher
#
cd ~/src
cd datapusher
pip install -r requirements.txt
pip install -e .


pip install -e "git+https://github.com/okfn/ckanext-spatial.git@stable#egg=ckanext-spatial"

