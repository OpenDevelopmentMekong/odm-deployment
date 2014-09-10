#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import urllib
import json
import pprint
import ckanapi
import logging
import traceback
import ckan
import re

# Migrate GeoServer layers to CKAN
# Using GeoServer's REST API. Obtain a list of the layers, pull their metadata
# along with GEOJson representation (if available) and link to OpenLayers and
# upload the information to CKAN creating a new dataset or modifying it in case
# it already exists.

# Metadata such as Title, abstract and Keywords could also be extracted from here:
# http://64.91.228.155:8181/geoserver/wfs?service=WFS&version=1.0.0&request=GetCapabilities

# Requires Ckanapi https://github.com/ckan/ckanapi

# TODO : Implement upload for GeoJSon file to avoid timeouts and/or proxy errors
# TODO : Implement tag support (creating the tag dictionary before adding tag)

log = logging.getLogger(__name__)

CKAN_URL = 'http://localhost'
CKAN_API = '<KEY>' # <KEY> ODM Importer's API Key
CKAN_ORGANISATION = 'odm-cambodia'
GEOSERVER_URL = 'http://64.91.228.155:8181/geoserver/'
GEOSERVER_AUTH = '<AUTH>' # <AUTH>
DEBUG = False

api = ckanapi.RemoteCKAN(CKAN_URL,apikey=CKAN_API)

request = urllib2.Request(GEOSERVER_URL+'rest/layers.json')
request.add_header('Authorization', GEOSERVER_AUTH)

# Make the HTTP request.
response = urllib2.urlopen(request)
assert response.code == 200

# Use the json module to load CKAN's response into a dictionary.
response_dict = json.loads(response.read())

# Define lists to store the created/modified datasets
dataset_count = 0
created_datasets = []
modified_datasets = []
not_found_datasets = []
error_datasets = []

# Loop through the JSON structure, we want to get the name of the layers:
# layers
#   | layer
#   	| Name

for key1, dict1 in response_dict.iteritems():

	if key1 == 'layers':

		for key2, dict2 in dict1.iteritems():

			if key2 == 'layer':

				for item in dict2: 
					
					# Now follow the link to a more detailed file
					urltocall = item['href']
					request = urllib2.Request(urltocall)
					request.add_header('Authorization', GEOSERVER_AUTH)

					# Make the HTTP request.
					response = urllib2.urlopen(request)
					assert response.code == 200

					# Use the json module to load CKAN's response into a dictionary.
					response_dict = json.loads(response.read())	

					if DEBUG: 
						pprint.pprint(response_dict)

					try:

						# Extract title, abstract and tags
						assert response_dict['layer']['resource']['href']     			        		

						# And again, another jump
						urltocall = response_dict['layer']['resource']['href'] 
						request = urllib2.Request(urltocall)
						request.add_header('Authorization', GEOSERVER_AUTH)

						# Make the HTTP request.
						response = urllib2.urlopen(request)
						assert response.code == 200

						# Use the json module to load CKAN's response into a dictionary.
						response_dict = json.loads(response.read())	

						if DEBUG: 
							pprint.pprint(response_dict)					

						# First, extract the information from the layer (Title, Abstract, Tags)	
						params_dict = {}					
						params_dict['author'] = 'ODM Importer'

						# The dataset id will be set when we find or create it
						params_dict['id'] = ''	

						# Extract title (Mandatory)
						feature = response_dict['featureType']
						if 'title' in feature:
							params_dict['title'] = feature['title']
						else:
							raise KeyError()

						# Extract name (Mandatory, lowcase and without characters except _-')
						if 'name' in feature:
							params_dict['name'] = feature['name'].lower()
						else:
							params_dict['name'] = params_dict['title']
						
						# Replace non-ascii characters and whitespaces
						params_dict['name'] = re.sub(r'[^\x00-\x7F]', '_', params_dict['name'])
						params_dict['name'] = params_dict['name'].replace(' ','_')

						print(params_dict['name'])

						# Notes / Description / Abstract
						if 'abstract' in feature:
							params_dict['notes'] = feature['abstract']	 
						else:
							params_dict['notes'] = 'Geoserver Layer '+params_dict['title']+'. Imported with migrate_geoserver_ckan.py'

						# Tags	
						# tag_dict_list = [dict({'name': 'imported',"vocabulary_id":"layers"})];         			       								
						# if 'keywords' in feature:
						# 	# Extract the tags and compose a dictionary for each one, storing it on a list							
						# 	for string in feature['keywords']['string']:
						# 		string_dict = dict({'name': string, "vocabulary_id":"layers"});
						# 		tag_dict_list.append(string_dict)																
						# params_dict['tags'] = tag_dict_list	

						# Namespace
						if 'namespace' in feature:
							params_dict['namespace'] = feature['namespace']['name']

						# Extras (Link to Geoserver)
						params_dict['extras'] = [dict({'key': 'geoserver_link','value': urltocall})]
						params_dict['extras'].append(dict({'key':'namespace','value':params_dict['namespace']}))

						# Define a list for the resources
						params_dict['resources'] = []

						# Get id of organisation from its name
						orga = api.action.organization_show(id=CKAN_ORGANISATION,include_datasets=False)

						# User CKAN api to call API's package_search
						try:	

							response = api.action.package_show(id=params_dict['name'].lower())

							if DEBUG: 
								pprint.pprint(response)

							# Lets modified it							
							modified_dataset = api.action.package_update(state='active',id=params_dict['name'].lower(),owner_org=orga['id'],name=params_dict['name'].lower(),title=params_dict['title'],author=params_dict['author'],notes=params_dict['notes'],extras=params_dict['extras'])
							# Add support for Tags tags=params_dict['tags']
							modified_datasets.append(modified_dataset['id'])
							params_dict['id'] = modified_dataset['id']

							print("Dataset modified with id ",modified_dataset['id'])

						except (ckanapi.SearchError,ckanapi.NotFound) as e:

							not_found_datasets.append(urltocall)

							# Lets create it							
							created_dataset = api.action.package_create(state='active',owner_org=orga['id'],name=params_dict['name'].lower(),title=params_dict['title'],author=params_dict['author'],notes=params_dict['notes'],extras=params_dict['extras'])							
							# Add support for Tags tags=params_dict['tags']

							created_datasets.append(created_dataset['id'])
							params_dict['id'] = created_dataset['id']

							print("Dataset created with id ",created_dataset['id'])						

					except KeyError:

						pprint.pprint("Dataset error")
						if DEBUG:
							traceback.print_exc()
						error_datasets.append(urltocall)
						continue

					try:

						# # Get the list of resources
						# response = api.action.package_show(id=params_dict['name'].lower())
						# pprint.pprint(response)
											
						# Append the link to the OpenLayers visualisation as resource
						ol_url = '<geoserver><namespace>/wms?service=WMS&version=1.1.0&request=GetMap&layers=<namespace>:<title>&styles=&bbox=211430.86563420878,1144585.4696614784,784623.3606298851,1625594.694892376&width=<width>&height=<height>&srs=EPSG:32648&format=application/openlayers'
						ol_url = ol_url.replace('<geoserver>',GEOSERVER_URL)
						ol_url = ol_url.replace('<namespace>',params_dict['namespace'])
						ol_url = ol_url.replace('<title>',params_dict['title'])
						ol_url = ol_url.replace('<width>','512')
						ol_url = ol_url.replace('<height>','429')

						created_resource = api.action.resource_create(package_id=params_dict['id'],description='OpenLayers',format='html',url=ol_url)

						# Append the link to the GeoJson file as resource
						ol_url = '<geoserver><namespace>/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=<namespace>:<title>&srsName=EPSG:4326&outputFormat=json'
						ol_url = ol_url.replace('<geoserver>',GEOSERVER_URL)
						ol_url = ol_url.replace('<namespace>',params_dict['namespace'])
						ol_url = ol_url.replace('<title>',params_dict['title'])

						created_resource = api.action.resource_create(package_id=params_dict['id'],description='GeoJson',format='geojson',url=ol_url)

					except ckanapi.NotFound:

						pprint.pprint("Dataset error")
						if DEBUG:
							traceback.print_exc()
						error_datasets.append(urltocall)
						continue

					# Print status
					print('%d Datasets imported',dataset_count)     			

# Print results
pprint.pprint("Import finished")
pprint.pprint("%d Datasets could not be retrieved correctly",len(error_datasets))
pprint.pprint("%d Datasets were not found",len(not_found_datasets))
pprint.pprint("%d Datasets were created",len(created_datasets))
pprint.pprint("%d Datasets were modified",len(modified_datasets))						
			
