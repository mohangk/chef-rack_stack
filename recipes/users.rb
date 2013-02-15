deploy_user  = node['chef-rack_stack']['deploy']['user']
deploy_group = node['chef-rack_stack']['deploy']['group']

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

group "#{deploy_group}" do
  action :create
  members deploy_user
end

