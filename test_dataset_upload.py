#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import urllib
import json
import pprint

# Upload a new dataset
# Uploads a new dataset to the CKAN instance specified on the code.

# TODO also upload resource

CKAN_URL = 'http://192.168.33.10'
CKAN_API_KEY = '63dfdb18-d1ee-421c-91ab-61c009725d3e'

# Put the details of the dataset we're going to create into a dict.
dataset_dict = {
    'name': 'TEST API Dataset',
    'title': 'title',
    'author': 'author',	
    'notes': 'A long description of my dataset'
}

# Use the json module to dump the dictionary to a string for posting.
data_string = urllib.quote(json.dumps(dataset_dict))

# We'll use the package_create function to create a new dataset.
request = urllib2.Request(CKAN_URL+'/api/action/package_create')

# Creating a dataset requires an authorization header.
# Replace *** with your API key, from your user account on the CKAN site
# that you're creating the dataset on.
request.add_header('Authorization', CKAN_API_KEY)

# Make the HTTP request.
response = urllib2.urlopen(request, data_string)
assert response.code == 200

# Use the json module to load CKAN's response into a dictionary.
response_dict = json.loads(response.read())
assert response_dict['success'] is True

# package_create returns the created package as its result.
created_package = response_dict['result']
pprint.pprint(created_package)