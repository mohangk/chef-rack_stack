node['postgresql']['password']  = {}
node['postgresql']['password']["postgres"]  = "password"

rails_environment  = 'development'                           #node['rack_stack']['environment']
appname            = 'Pie'                                   #node['rack_stack']['application_name']
deploy_user        = 'neo_deploy'                            #node['rack_stack']['deploy_user']
deploy_group       = 'neo_deploy'                            #node['rack_stack']['deploy_group']
app_repository     = 'git://github.com/mohangk/fastrego.git' #node['rack_stack']['deploy_group']

base_path = "/home/#{deploy_user}/#{appname}"
instance_name = [appname, rails_environment].join("_")

ohai "reload_passwd" do
  action :nothing
  plugin 'passwd'
end

user_account deploy_user do
  comment "Deploy user"
  home "/home/#{deploy_user}"
  #ssh_keys node['rack_stack']['deploy_user_authorized_key']
  notifies :reload, resources(:ohai => 'reload_passwd'), :immediately
end

include_recipe 'postgresql::server'
include_recipe 'ruby::1.9'

#stage_data = {'enable'=> true, 'enable_ssl' => false, 'hostname' => 'localhost'}
## Set up directory and file name info for SSL certs
#ssl_dir        = (stage_data['enable_ssl']) ? "/etc/apache2/ssl/#{appname}/#{rails_environment}/" : ""
#ssl_cert_file  = (stage_data['enable_ssl']) ? "#{instance_name}.crt" : ""
#ssl_key_file   = (stage_data['enable_ssl']) ? "#{instance_name}.key" : ""
#ssl_chain_file = (stage_data['enable_ssl']) ? "#{instance_name}-bundle.crt" : ""

# Create directory for the app
directory base_path do
  owner deploy_user
  group deploy_group
  mode "2755" # set gid so group sticks if it's different than user
  action :create
  recursive true
end

bash "Set Directory Owner" do
  user "root"
  cwd "/home/#{deploy_user}"
  code <<-EOH
    chown -R #{deploy_user}:#{deploy_group} *
  EOH
end

application instance_name do
  name             appname
  path             "#{base_path}"
  owner            deploy_user
  group            deploy_group
  repository       app_repository
  environment_name rails_environment
  #restart_command  "ls /tmp"

  before_restart do
    directory "#{base_path}/current/tmp" do
      owner deploy_user
      group deploy_group
      mode "2755" # set gid so group sticks if it's different than user
      action :create
    end
  end

#  server_name               localhost #stage_data['hostname']
#  server_aliases            [] #stage_data['aliases'] || []
#  server_admin              stage_data['admin'] || 'root@localhost'
#  ip_address                stage_data['ip_address'] || '*'
#  port                      stage_data['port'] || 80
#  redirect_from             stage_data['redirect_from']
#  passenger_min_instances   stage_data['min_instances'] || 1
#  enable                    stage_data['enable']
#  enable_ssl                stage_data['enable_ssl']
#  ssl_port                  stage_data['ssl_port'] || 443
#  ssl_cert_file             ssl_dir + ssl_cert_file
#  ssl_cert_key_file         ssl_dir + ssl_key_file
#  ssl_cert_chain_file       ssl_dir + ssl_chain_file

  rails do
    gems ['bundler']
    bundler true
  end

  passenger_apache2 do
    webapp_template   "web_app.conf.erb"
  end
end
