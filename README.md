scripting
=========

Repository to host utility scripts to add/migrate/update data in the different modules. 

### scripts

1. Taxonomy Tags creation script // taxonomy_tag_creation.py

Reads a JSON file containing ODM taxonomy in a specific language. Loops it generating Tag Vocabularies, pushing them into CKAN in order to replicate ODM's Taxonomy on CKAN, see 1.2.8 of M1 Viability Research.

2. Migrate GeoServer layers to CKAN // migrate_geoserver_ckan.py

Using GeoServer's REST API. Obtain a list of the layers, pull their metadata along with GEOJson representation (if available) and link to OpenLayers and upload the information to CKAN creating a new dataset or modifying it in case it already exists.

2. Retrieve a dataset test // test_dataset_retrieve.py

Retrieves a certain dataset from the CKAN collection and outputs its JSON representation.

3. Query the database and search for datasets // test_dataset_search_query.py

Searches the database of a CKAN instance with a query specified in code. The list of datasets containing that query on their metadata are returned as a JSON list.

4. Upload a new dataset // test_dataset_upload.py

Uploads a new dataset to the CKAN instance specified on the code.
