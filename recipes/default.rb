rails_environment  = node['chef-rack_stack']['rails']['environment']
appname            = node['chef-rack_stack']['app']['name']
app_repository     = node['chef-rack_stack']['app']['repo']
deploy_user        = node['chef-rack_stack']['deploy']['user']
deploy_group       = node['chef-rack_stack']['deploy']['group']
base_path          = "/home/#{deploy_user}/#{appname}"
instance_name      = "#{appname}_#{rails_environment}"
db_name            = node['chef-rack_stack']['app']['db']
db_password        = node['postgresql']['password']['postgres']

include_recipe 'chef-rack_stack::users'
include_recipe 'chef-rack_stack::apt'

include_recipe 'apt'
include_recipe 'postgresql::server'
include_recipe 'ruby'
include_recipe 'git'
include_recipe 'xml'
include_recipe 'nodejs'
include_recipe 'imagemagick'
include_recipe 'imagemagick::devel'
include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_proxy_balancer'

package 'make'

include_recipe 'chef-rack_stack::rails'
include_recipe 'chef-rack_stack::apache_reverse_proxy'
