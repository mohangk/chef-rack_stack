deploy_user  = node['chef-rack_stack']['deploy']['user']
deploy_group = node['chef-rack_stack']['deploy']['group']
deploy_ssh_key = node['chef-rack_stack']['deploy']['ssh_key']

ohai "reload_passwd" do
  action :nothing
  plugin 'passwd'
end

user_account deploy_user do
  comment "Deploy user"
  home "/home/#{deploy_user}"
  ssh_keys deploy_ssh_key
  notifies :reload, resources(:ohai => 'reload_passwd'), :immediately
end

group "#{deploy_group}" do
  action :create
  members deploy_user
end

