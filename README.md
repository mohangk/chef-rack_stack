## <a name="description"></a> Description

A simple cookbook to spin up a server with:

* Apache
* Passenger
* RVM 
* Postgres
* Memcached
* Redis

The key differentiator here is the same cookbook can be used for either on a Vagrant 
instance locally or a EC2 instance. This way both local development and production 
can be kept in sync. This cookboook was created to be used in tandem with
[easy_rack_stack][easy_rack_stack] project.

The cookbook has been tested with Ubuntu 12.04.

* Github: https://github.com/newcontext/chef-rack_stack

This cookbook depends on great work by https://github.com/fnichol and 
https://github.com/coroutine.


## <a name="status"></a> Status

This cookbook is incomplete. Use at your own peril.

## <a name="usage"></a> Usage

Simply include `recipe[chef-user_stack]` in your run\_list and setup the relavant 
attributes. (More information required)

## <a name="requirements"></a> Requirements


### <a name="requirements-chef"></a> Chef

Tested on 0.10.8 but newer and older version should work just fine. File an
[issue][issues] if this isn't the case.

### <a name="requirements-platform"></a> Platform

The following platforms have been tested with this cookbook, meaning that the
recipes run on these platforms without error:

* ubuntu

### <a name="requirements-cookbooks"></a> Cookbooks

There are tons of dependencies, but they have not been enetered into metadata.rb 
yet but instead maintained externally in the [Cheffile][cheffile] contained in the 
[easy_rack_stack] project. This will be fixed soon. For now please  refer to

## <a name="recipes"></a> Recipes

### <a name="recipes-default"></a> default

This is the only recipe. 

## <a name="attributes"></a> Attributes

### <a name="attributes-environment"></a> environment

The Rack environment, 'production' or 'development'

### <a name="attributes-appname"></a> appname

A unique name to identify the application that you are deploying. 

### <a name="attributes-deploy-user"></a> deploy_user 

The system user that will perform the deployment and act as owner of the created files. 
A group with the same name is automatically created and set as owner-group.

### <a name="attributes-deploy-user-authorizd-key"></a> deploy_user_authorized_key 

Public key to be added to ~/.ssh/authorized_keys for SSH access.

## <a name="license"></a> License and Author

Copyright 2012, {new context}

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[easy_rack_stack]: https://github.com/newcontext/easy_rack_stack
[cheffile]: https://github.com/newcontext/easy_rack_stack/blob/master/Cheffile
