#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Import from Geoserver
# This script imports all Layers from GeoServer using the import_from_geoserver function
# from the ODMImporter.

# NOTE: This script has to be run within a virtual environment!!!
# Do not forget to set the correct API Key while initialising RealCkanApi
# . /usr/lib/ckan/default/bin/activate

import sys
sys.path.append('/usr/lib/ckan/default/src/ckanext-odm_utils/ckanext/odm_utils/utils')
import ckanapi_utils
import github_utils
from odm_importer import ODMImporter

# Initialise RealGithubApi
githubutils = github_utils.RealGithubApi()

# Initialise RealCkanApi (URL and APIKEY must be specified)
ckanapiutils = ckanapi_utils.RealCkanApi('http://localhost:8080','<CKAN_ADMIN_API_KEY>')

importer = ODMImporter()
importer.import_taxonomy_term_translations(githubutils,ckanapiutils)


