#!/usr/bin/env python
import urllib2
import urllib
import json
import pprint

# Migrate GeoServer layers to CKAN
# Using GeoServer's REST API. Obtain a list of the layers, pull their metadata
# along with GEOJson representation (if available) and link to OpenLayers and
# upload the information to CKAN creating a new dataset or modifying it in case
# it already exists.

CKAN_URL = 'http://ubuntuserver'
CKAN_API = 'a3060884-a774-4b1f-8c0e-c665c8119dca'
GEOSERVER_URL = 'http://64.91.228.155:8181/geoserver/rest/'
GEOSERVER_AUTH = 'Basic b2RjX3Rlc3Q6QCMlQCQjT3BlbmRBdGE='

request = urllib2.Request(GEOSERVER_URL+'layers.json')
request.add_header('Authorization', GEOSERVER_AUTH)

# Make the HTTP request.
response = urllib2.urlopen(request)
assert response.code == 200

# Use the json module to load CKAN's response into a dictionary.
response_dict = json.loads(response.read())

# Loop through the JSON structure, we want to get the name of the layers:
# layers
#   | layer
#   	| Name

for key1, dict1 in response_dict.iteritems():
    if key1 == 'layers':
    	for key2, dict2 in dict1.iteritems():
            if key2 == 'layer':
            	for item in dict2:  

            			# First, we check if a dataset with the same geoserver_link already exists

            			# Put the details of the dataset we're going to create into a dict.
						params_dict = {
						    'q': item['href'],    
						}

						# Use the json module to dump the dictionary to a string for posting.
						data_string = urllib.quote(json.dumps(params_dict))

						# We'll use the package_create function to create a new dataset.
						request = urllib2.Request(CKAN_URL+'/api/3/action/package_search')

						# Make the HTTP request.
						response = urllib2.urlopen(request, data_string)
						assert response.code == 200

						# Use the json module to load CKAN's response into a dictionary.
						response_dict = json.loads(response.read())
						assert response_dict['success'] is True

						package = None

						# check if there is on match					
						if response_dict['count'] == 1:
							
							# Store the found dataset
							package = response_dict['result']

							dataset_dict = {
							    'name': item['name'],
							    'title': item['name'],
							    'author': 'ODM Admin',	
							    'geoserver_link': item['href'],	
							    'notes': 'A long description of my dataset'
							}

							data_string = urllib.quote(json.dumps(dataset_dict))

							# We'll use the package_create function to create a new dataset.
							request = urllib2.Request(CKAN_URL+'/api/action/package_update')
							request.add_header('Authorization', CKAN_API)

							response = urllib2.urlopen(request, data_string)
							assert response.code == 200

							response_dict = json.loads(response.read())
							assert response_dict['success'] is True

							package = response_dict['result']

						else :

	            			# Prepare dictionary with dataset metadata   
	            			dataset_dict = {
							    'name': item['name'],
							    'title': item['name'],
							    'author': 'ODM Admin',	
							    'geoserver_link': item['href'],	
							    'notes': 'A long description of my dataset'
							}       	 	

							data_string = urllib.quote(json.dumps(dataset_dict))

							# We'll use the package_create function to create a new dataset.
							request = urllib2.Request(CKAN_URL+'/api/action/package_create')
							request.add_header('Authorization', CKAN_API)

							response = urllib2.urlopen(request, data_string)
							assert response.code == 200

							response_dict = json.loads(response.read())
							assert response_dict['success'] is True

							package = response_dict['result']

						# if successfull, append datasets

						# First, compose call to GEOJson representation, store in temp file and upload.

						# Second, compose call to OpenLayers representation and link it as resource.

						# Make call to resource_create


            			
            			