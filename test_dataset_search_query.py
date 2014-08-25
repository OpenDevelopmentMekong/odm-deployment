#!/usr/bin/env python
import urllib2
import urllib
import json
import pprint

# Query the database and search for datasets
# Searches the database of a CKAN instance with a query specified in code. 
# The list of datasets containing that query on their metadata are returned as a JSON list.

CKAN_URL = 'http://ubuntuserver'
QUERY = 'test'

# Put the details of the dataset we're going to create into a dict.
params_dict = {
    'q': QUERY,    
}

# Use the json module to dump the dictionary to a string for posting.
data_string = urllib.quote(json.dumps(params_dict))

# We'll use the package_create function to create a new dataset.
request = urllib2.Request(CKAN_URL+'/api/3/action/package_search')

# No authorisation header needed for this action
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