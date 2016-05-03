#!/usr/bin/env bash

# Bootstrap the Vagrant VM by installing Ansible
# and let Ansible handle the rest.
# Make sure we're up to date
sudo apt-get update

# Install git, easy_install, pip and extra packages needed by ansible
sudo apt-get install -y git-core
sudo apt-get install -y python-setuptools
sudo apt-get install -y python-dev
sudo easy_install pip
sudo pip install jinja2 paramiko PyYAML httplib2

# Clone mishari's patched version of ansible
git clone -b release1.8.1_sync_fix https://github.com/mishari/ansible.git --recursive
cd ./ansible
source ./hacking/env-setup

# Run ansible playbooks with instructions to provision the VM
ansible-playbook /vagrant/ansible/site-vagrant.yml -i /vagrant/ansible/stage --connection=local -vvvv
