rails_environment  = node['chef-rack_stack']['rails']['environment']
appname            = node['chef-rack_stack']['app']['name']
app_repository     = node['chef-rack_stack']['app']['repo']
deploy_user        = node['chef-rack_stack']['deploy']['user']
deploy_group       = node['chef-rack_stack']['deploy']['group']
base_path          = "/home/#{deploy_user}/#{appname}"
git_repo_path      = "#{base_path}.git"
instance_name      = "#{appname}_#{rails_environment}"
db_name            = node['chef-rack_stack']['app']['db']
db_password        = node['postgresql']['password']['postgres']

include_recipe 'ruby'
include_recipe 'git'
include_recipe 'xml'
include_recipe 'nodejs'
package 'make'
package 'runit'

directory base_path do
  owner deploy_user
  group deploy_group
  mode "2755" # set gid so group sticks if it's different than user
  action :create
  recursive true
end

directory git_repo_path do
  owner deploy_user
  group deploy_group
  mode "2755"
  action :create
  recursive true
end

execute 'create_bare_git_repo' do
  command "git init --bare #{git_repo_path}"
  user deploy_user
  group deploy_user
  not_if do
    File.exists? "{git_repo_path}/hooks"
  end
end
