#!/usr/bin/env python
import urllib2
import urllib
import json
import pprint

# Taxonomy Tags creation script
# Reads a JSON file containing ODM taxonomy in a specific language.
# Loops it generating Tag Vocabularies, pushing them into CKAN in
# order to replicate ODM's Taxonomy on CKAN, see 1.2.8 of M1
# Viability Research

# TODO
# Load taxonomy JSON from file
# Execute on productions CKAN instance after testing its validity

CKAN_URL = 'http://ubuntuserver'
CKAN_API = 'a3060884-a774-4b1f-8c0e-c665c8119dca'
TAXONOMY_FILE = ''

# Create vocabulary tags
vocabulary = {
    'name': 'Agriculture and fishing',
    'children' : {
    	'Agriculture',
    	'Fishing, fisheries, aquaculture'
    }
}

vocabulary_name = 'notdef'
for k, v in vocabulary.items():	
	if k == 'name':
		print(v)
		vocabulary_name = v
	elif k == 'children':
		for tag in v:
			#Add each of the tags in the vocabulary
			print('Inserting tag ' + tag + ' in vocabulary ' + vocabulary_name)
			data_string = urllib.quote(json.dumps(dict([('name', tag), ('vocabulary_id', vocabulary_name)])))
			request = urllib2.Request(CKAN_URL+'/api/action/tag_create')
			request.add_header('Authorization', CKAN_API)
			response = urllib2.urlopen(request, data_string)
			assert response.code == 200

			response_dict = json.loads(response.read())
			assert response_dict['success'] is True

			created_tag = response_dict['result']
			pprint.pprint(created_tag)
	