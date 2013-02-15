appname = node['chef-rack_stack']['app']['name']

web_app appname do
  docroot "#{base_path}/current"
  template "chef-rack_stack_app.conf.erb"
  server_name "#{appname}"
end

apache_site "000-default" do
  enable false
end

