#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Insert initial ODM Data
# This script initialises the CKAN Instance with a list of organizations, groups and users:
# organizations (ODM Cambodia, ODM Laos, ODM Thailand, ODM Vietnam, ODM Myanmar)
# Groups (Cambodia, Laos, Thailand, Vietnam, Myanmar)
# Users (odmcambodia, odmlaos, odmthailand, odmvietnam, odmmyanmar)

# NOTE: This script has to be run within a virtual environment!!!
# Do not forget to set the correct API Key while initialising RealCkanApi
# . /usr/lib/ckan/default/bin/activate

import sys
sys.path.append('<PATH_TO_ODM_UTILS_PLUGIN>/ckanext/odm_utils/utils')
import ckanapi_utils
import ckan
from odm_importer import ODMImporter

# Initialise RealCkanApi (APIKEY must be specified)
ckanapiutils = ckanapi_utils.RealCkanApi('<CKAN_URL_AND_PORT>','<CKAN_ADMIN_API_KEY>')

# Add Users
try:

	ckanapiutils.add_user('odmcambodia','cambodia@opendevelopmentmekong.net','Khcam#%Mkong','ODM Cambodia admin')
	ckanapiutils.add_user('odmlaos','laos@opendevelopmentmekong.net','LoLa#%Mkong','ODM Laos admin')
	ckanapiutils.add_user('odmthailand','thailand@opendevelopmentmekong.net','ThTH#%Mkong','ODM Thailand admin')
	ckanapiutils.add_user('odmvietnam','vietnam@opendevelopmentmekong.net','Vivn#%Mkong','ODM Vietnam admin')
	ckanapiutils.add_user('odmmyanmar','myanmar@opendevelopmentmekong.net','MMMy#%Mkong','ODM Myanmar admin')

except ckan.logic.ValidationError:

	print 'Users already added'

# Add organizations
try:

	ckanapiutils.add_organization('cambodia_organization','ODM Cambodia','organization for Cambodia')
	ckanapiutils.add_organization('laos_organization','ODM Laos','organization for Laos')
	ckanapiutils.add_organization('thailand_organization','ODM Thailand','organization for Thailand')
	ckanapiutils.add_organization('vietnam_organization','ODM Vietnam','organization for Vietnam')
	ckanapiutils.add_organization('myanmar_organization','ODM Myanmar','organization for Myanmar')

except ckan.logic.ValidationError:

	print 'Organizations already added'

# Add admins to organizations
try:

	ckanapiutils.add_admin_to_organization('cambodia_organization','odmcambodia','admin')
	ckanapiutils.add_admin_to_organization('laos_organization','odmlaos','admin')
	ckanapiutils.add_admin_to_organization('thailand_organization','odmthailand','admin')
	ckanapiutils.add_admin_to_organization('vietnam_organization','odmvietnam','admin')
	ckanapiutils.add_admin_to_organization('myanmar_organization','odmmyanmar','admin')

except ckan.logic.ValidationError:

	print 'Users already admined'

# Add groups
try:

	ckanapiutils.add_group('cambodia_group','Cambodia','Group for Cambodia')
	ckanapiutils.add_group('laos_group','Laos','Group for Laos')
	ckanapiutils.add_group('thailand_group','Thailand','Group for Thailand')
	ckanapiutils.add_group('vietnam_group','Vietnam','Group for Vietnam')
	ckanapiutils.add_group('myanmar_group','Myanmar','Group for Myanmar')

except ckan.logic.ValidationError:

	print 'Groups already added'
