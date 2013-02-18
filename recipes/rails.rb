rails_environment  = node['chef-rack_stack']['rails']['environment']
appname            = node['chef-rack_stack']['app']['name']
app_repository     = node['chef-rack_stack']['app']['repo']
deploy_user        = node['chef-rack_stack']['deploy']['user']
deploy_group       = node['chef-rack_stack']['deploy']['group']
base_path          = "/home/#{deploy_user}/#{appname}"
instance_name      = "#{appname}_#{rails_environment}"
db_name            = node['chef-rack_stack']['app']['db']
db_password        = node['postgresql']['password']['postgres']

include_recipe 'ruby'
include_recipe 'git'
include_recipe 'xml'
include_recipe 'nodejs'
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

  unicorn do
    bundler true
    preload_app true
    worker_processes 10
    port '127.0.0.1:5000'
    worker_timeout 30
  end
end


