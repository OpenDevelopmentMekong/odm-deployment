#!/usr/bin/env bash

# Bootstrap the Vagrant VM by installing Ansible
# and let Ansible handle the rest.
# Make sure we're up to date
apt-get update
# Install Ansible
apt-get install -y software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y ansible
# Run playbook to provision up VM
# This just installs git and checks out this repo
ansible-playbook /vagrant/ansible/bootstrap.yml -i /vagrant/ansible/hosts --connection=local
# Run Noop for a Proof of concept
cd vagrant-bootstrap
ansible-playbook ansible/site-vagrant.yml -i ansible/hosts --connection=local