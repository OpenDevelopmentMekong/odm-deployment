#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import urllib
import json
import pprint

# Retrieve a dataset test
# Retrieves a certain dataset from the CKAN collection and outputs its 
# JSON representation.

CKAN_URL = 'http://ubuntuserver'
DATASET_ID = 'hallo'

# Put the details of the dataset we're going to create into a dict.
params_dict = {
    'id': DATASET_ID,    
}

# Use the json module to dump the dictionary to a string for posting.
data_string = urllib.quote(json.dumps(params_dict))

# We'll use the package_create function to create a new dataset.
request = urllib2.Request(CKAN_URL+'/api/3/action/package_show')

# No need for authorisation for this call
#request.add_header('Authorization', 'a3060884-a774-4b1f-8c0e-c665c8119dca')

# Make the HTTP request.
response = urllib2.urlopen(request, data_string)
assert response.code == 200

# Use the json module to load CKAN's response into a dictionary.
response_dict = json.loads(response.read())
assert response_dict['success'] is True

# package_create returns the created package as its result.
created_package = response_dict['result']
pprint.pprint(created_package)