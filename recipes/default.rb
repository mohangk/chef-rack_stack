environment = node['rack_stack']['environment']
appname = 'Pie'
deploy_user = node['rack_stack']['deploy_user']
deploy_group = node['rack_stack']['deploy_group']

base_path = "/home/#{deploy_user}/#{appname}"
instance_name = [appname, environment].join("_")

ohai "reload_passwd" do
  action :nothing
  plugin 'passwd'
end

user_account deploy_user do
  comment "Deploy user"
  home "/home/#{deploy_user}"
  ssh_keys node['rack_stack']['deploy_user_authorized_key']
  notifies :reload, resources(:ohai => 'reload_passwd'), :immediately
end

include_recipe 'apache2::default'
include_recipe 'apache2::mod_expires'
include_recipe "apache2::mod_xsendfile"
include_recipe 'rvm::system'
include_recipe 'memcached'

#we don't want this when deploying on EC2
if node[:instance_role] == 'vagrant'
  include_recipe 'rvm::vagrant'
end

include_recipe 'rvm_passenger::default'
include_recipe 'rvm_passenger::apache2'
include_recipe 'chef-postgresql::server'

include_recipe 'nodejs'
include_recipe 'imagemagick'
include_recipe 'imagemagick::devel'
include_recipe 'redisio::install'
include_recipe 'redisio::enable'

stage_data = {'enable'=> true, 'enable_ssl' => false, 'hostname' => 'localhost'}
# Set up directory and file name info for SSL certs
ssl_dir        = (stage_data['enable_ssl']) ? "/etc/apache2/ssl/#{appname}/#{environment}/" : ""
ssl_cert_file  = (stage_data['enable_ssl']) ? "#{instance_name}.crt" : ""
ssl_key_file   = (stage_data['enable_ssl']) ? "#{instance_name}.key" : ""
ssl_chain_file = (stage_data['enable_ssl']) ? "#{instance_name}-bundle.crt" : ""

# Create directory for the app
directory base_path do
  owner deploy_user
  group deploy_group
  mode "2755" # set gid so group sticks if it's different than user
  action :create
  recursive true  # mkdir -p
end

bash "Set Directory Owner" do
  user "root"
  cwd "/home/#{deploy_user}"
  code <<-EOH
    chown -R #{deploy_user}:#{deploy_group} *
  EOH
end

app_config(instance_name) do
  docroot                   "#{base_path}/current/public"
  rack_env                  environment
  server_name               stage_data['hostname']
  server_aliases            stage_data['aliases'] || []
  server_admin              stage_data['admin'] || 'root@localhost'
  ip_address                stage_data['ip_address'] || '*'
  port                      stage_data['port'] || 80
  redirect_from             stage_data['redirect_from']
  template                  "apache.conf.erb"
  passenger_min_instances   stage_data['min_instances'] || 1
  enable                    stage_data['enable']
  enable_ssl                stage_data['enable_ssl']
  ssl_port                  stage_data['ssl_port'] || 443
  ssl_cert_file             ssl_dir + ssl_cert_file
  ssl_cert_key_file         ssl_dir + ssl_key_file
  ssl_cert_chain_file       ssl_dir + ssl_chain_file
end

# Disable Apache's default site
apache_site "000-default" do
  enable false
end
