rails_environment  = node['chef-rack_stack']['rails']['environment']
appname            = node['chef-rack_stack']['app']['name']
app_repository     = node['chef-rack_stack']['app']['repo']
deploy_user        = node['chef-rack_stack']['deploy']['user']
deploy_group       = node['chef-rack_stack']['deploy']['group']
base_path          = "/home/#{deploy_user}/#{appname}"
instance_name      = "#{appname}_#{rails_environment}"
db_name            = node['chef-rack_stack']['app']['db']
db_password        = node['postgresql']['password']['postgres']

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

group "neo_deploy" do
  action :create
  members "neo_deploy"
end

file "/var/lib/apt/periodic/update-success-stamp" do
  action :delete
end

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

# Create directory for the app
directory base_path do
  owner deploy_user
  group deploy_group
  mode "2755" # set gid so group sticks if it's different than user
  action :create
  recursive true
end

application instance_name do
  name             appname
  path             "#{base_path}"
  owner            deploy_user
  group            deploy_group
  repository       app_repository
  environment_name rails_environment

  before_restart do
    directory "#{base_path}/current/tmp" do
      owner deploy_user
      group deploy_group
      mode "2755" # set gid so group sticks if it's different than user
      action :create
    end
  end

  before_symlink do

    execute 'create_and_migrate_database' do
      command 'bundle exec rake db:create db:migrate'
      user deploy_user
      group deploy_group
      cwd release_path
      environment ({'RAILS_ENV' => rails_environment })
    end

    execute 'compile_assets' do
      command 'bundle exec rake assets:precompile'
      user deploy_user
      group deploy_group
      cwd release_path
      environment ({'RAILS_ENV' => rails_environment })
    end
  end

  rails do
    gems ['bundler']
    bundler true
    bundle_command '/usr/local/bin/bundle'
    database do
      adapter "postgresql"
      database db_name
      pool "5"
      username 'postgres'
      password db_password
      host 'localhost'
    end
  end

  #passenger_apache2 do
  #  webapp_template "web_app.conf.erb"
  #end

  unicorn do
    bundler true
    preload_app true
    worker_processes 10
    port '127.0.0.1:5000'
    worker_timeout 30
  end

end

web_app appname do
  docroot "#{base_path}/current"
  template "chef-rack_stack_app.conf.erb"
  server_name "#{appname}"
end

apache_site "000-default" do
  enable false
end
