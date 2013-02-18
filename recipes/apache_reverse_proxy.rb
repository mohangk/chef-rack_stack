appname = node['chef-rack_stack']['app']['name']

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_proxy_balancer'

web_app appname do
  docroot "#{base_path}/current"
  template "chef-rack_stack_app.conf.erb"
  server_name "#{appname}"
end

apache_site "000-default" do
  enable false
end

