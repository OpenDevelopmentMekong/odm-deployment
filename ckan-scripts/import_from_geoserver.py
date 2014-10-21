#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Import from Geoserver
# This script imports all Layers from GeoServer using the import_from_geoserver function
# from the ODMImporter.

# NOTE: This script has to be run within a virtual environment!!!
# Do not forget to set the correct API Key while initialising RealCkanApi
# . /usr/lib/ckan/default/bin/activate

import sys
sys.path.append('<PATH_TO_ODM_UTILS_PLUGIN>/ckanext/odm_utils/utils')
import geoserver_utils
import ckanapi_utils
import github_utils
from odm_importer import ODMImporter

geoserverutils = geoserver_utils.RealGeoserverRestApi('<GEOSERVER_URL_AND_PORT>','<GEOSERVER_BASIC_AUTH>')
ckanapiutils = ckanapi_utils.RealCkanApi('<CKAN_URL_AND_PORT>','<CKAN_ADMIN_API_KEY>')

importer = ODMImporter()
importer.import_from_geoserver(geoserverutils,ckanapiutils)
