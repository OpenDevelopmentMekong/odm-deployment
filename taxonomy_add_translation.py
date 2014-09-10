#!/usr/bin/env python
# coding: utf-8
import urllib2
import urllib
import json
import pprint

# Taxonomy Tags creation script
# Adds a single tranlation to CKAN, for a term in a certain language.
# This script is good for testing.


CKAN_URL = 'http://192.168.33.10'
CKAN_API_KEY = '<KEY>' 	# <KEY>

# Create vocabulary tags
params_dict = {
    'term': 'Cambodia', 
    'translation' : 'ប្រទេសកម្ពុជា',
    'lang_code' : 'kh'   
}

# Use the json module to dump the dictionary to a string for posting.
data_string = urllib.quote(json.dumps(params_dict))

# We'll use the package_create function to create a new dataset.
request = urllib2.Request(CKAN_URL+'/api/3/action/term_translation_update')

# No need for authorisation for this call
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
	