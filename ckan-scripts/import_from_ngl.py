#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Import from NextGenLib
# This script imports all records from a MARC21 formatted file (available on github)
# as datasets.

# NOTE: This script has to be run within a virtual environment!!!
# Do not forget to set the correct API Key while initialising RealCkanApi
# . /usr/lib/ckan/default/bin/activate

import sys
sys.path.append('<PATH_TO_ODM_UTILS_PLUGIN>/ckanext/odm_utils/utils')
import github_utils
import ckanapi_utils
import github_utils
from odm_importer import ODMImporter

githubutils = github_utils.RealGithubApi()
ckanapiutils = ckanapi_utils.RealCkanApi('<CKAN_URL_AND_PORT>','<CKAN_ADMIN_API_KEY>')

importer = ODMImporter()
importer.import_marc21_library_records(githubutils,ckanapiutils,"<ORGA_NAME>","<GROUP_NAME>")
