#!/usr/bin/env python
import urllib2
import urllib
import json
import pprint

# Retrieve the translation for a specified terms
# Taxonomy has been translated and inserted in different languages, this script
# allows to check which translations for a specified term are stored in CKAN

CKAN_URL = 'http://192.168.33.10/'

# Specify the terms to look for
params_dict = {
    'terms': ['Russian', 'romantic novel'], 
    'lang_codes' : ['en','de','es']   
}

# Use the json module to dump the dictionary to a string for posting.
data_string = urllib.quote(json.dumps(params_dict))

# We'll use the package_create function to create a new dataset.
request = urllib2.Request(CKAN_URL+'/api/3/action/term_translation_show')

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