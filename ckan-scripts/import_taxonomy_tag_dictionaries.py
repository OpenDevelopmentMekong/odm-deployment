#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Import from Geoserver
# This script imports all Layers from GeoServer using the import_from_geoserver function
# from the ODMImporter.

# NOTE: This script has to be run within a virtual environment!!!
# . /usr/lib/ckan/default/bin/activate

import sys
sys.path.append('/usr/lib/ckan/default/src/ckanext-odm_utils/ckanext/odm_utils/utils')
import geoserver_utils
import ckanapi_utils
import github_utils
from odm_importer import ODMImporter

githubutils = github_utils.RealGithubApi()
ckanapiutils = ckanapi_utils.RealCkanApi('http://localhost','a7178e80-7065-45a6-ad07-c3c9accc7097')

importer = ODMImporter()
importer.import_taxonomy_tag_dictionaries(githubutils,ckanapiutils)


