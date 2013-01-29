## <a name="description"></a> Description

A simple Chef cookbook to spin up a server that is capable to host a Rails application. 

* Apache (reverse proxy)
* Unicorn 
* Postgres

It handles the following

 1. Installation and setting up of all the server related services.
 1. Deployment of application from a git repository
 1. Running of `bundle install`, `rake assets:precompile` and `rake db:migrate`
 
It be used to update an existing setup. When run again it will checkout and deploy the latest code and re-run `bundle install`, `rake assets:precompile` and `rake db:migrate` 

Github: https://github.com/newcontext/chef-rack_stack

## <a name="status"></a> Status

Still a work in progress but should be usable for a simple monolithic setup.

## <a name="usage"></a> Usage

Simply include `recipe[chef-rack_stack]` in your run\_list and setup the relavant attributes.

## <a name="requirements"></a> Requirements


### <a name="requirements-chef"></a> Chef

Tested on 0.10.8 but newer and older version should work just fine. File an
[issue][issues] if this isn't the case.

### <a name="requirements-platform"></a> Platform

The following platforms have been tested with this cookbook, meaning that the
recipes run on these platforms without error:

* Ubuntu 12.10

## <a name="recipes"></a> Recipes

### <a name="recipes-default"></a> default

This is the only recipe. 

## <a name="attributes"></a> Attributes


### <a name="attributes-environment"></a> environment

node['chef-rack_stack']['rails'['environment'] - The Rack environment, 'production' or 'development'

### <a name="attributes-appname"></a> appname

node['chef-rack_stack']['app']['name'] - A unique name to identify the application that you are deploying. 


### <a name="attributes-deploy-user"></a> deploy_user, deploy_group

node['chef-rack_stack']['deploy']['user']- The system user that will perform the deployment and act as owner of the created files. 

node['chef-rack_stack']['deploy']['group']- The group the created files will belong to.

### <a name="attributes-repo"></a> repo

node['chef-rack_stack']['app']['repo'] - The url to the git repository that the application will be checked out from.

### <a name="attributes-repo"></a> db, postgres user password

node['chef-rack_stack']['app']['db'] - The name of postgres database that will be created for the application

node['postgresql']['password']['postgres'] - The password that will be used for the database


## <a name="license"></a> License and Author

Copyright 2012, Mohan Krishnan, Abhaya Shenoy, Winston Teo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
