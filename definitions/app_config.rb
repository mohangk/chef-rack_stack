# This is a modified version of Opscode's apache2 web_app 
# definition. It's been renamed "app_config" and it includes
# a bugfix for COOK-994:
#
# http://tickets.opscode.com/browse/COOK-994
#
# This code was originally from the "apache2" cookbook.
#
# Cookbook Name:: rails_apps
# Definition:: web_app
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :app_config, :template => "apache.conf.erb", :enable => true do

  application_name = params[:name]
  enable_app = params[:enable]  # whether or not we run a2ensite or a2dissite
  
  include_recipe "apache2"
  include_recipe "apache2::mod_rewrite"
  include_recipe "apache2::mod_deflate"
  include_recipe "apache2::mod_headers"
  
  template "#{node[:apache][:dir]}/sites-available/#{application_name}.conf" do
    source params[:template]
    owner "root"
    group node[:apache][:root_group]
    mode 0644
    if params[:cookbook]
      cookbook params[:cookbook]
    end
    variables(
      :application_name => application_name,
      :params => params
    )
    if ::File.exists?("#{node[:apache][:dir]}/sites-enabled/#{application_name}.conf")
      notifies :reload, resources(:service => "apache2"), :delayed
    end
  end
  
  apache_site "#{params[:name]}.conf" do
    enable enable_app
  end
end
