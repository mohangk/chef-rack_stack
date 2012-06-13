#
# Cookbook Name:: rails_apps 
# Recipe:: apache_config
#
# Copyright 2012, Coroutine LLC
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

app_configs = []

node['rails_apps'].each do |dbag_item|
  # NOTE: shared secret must be in "/etc/chef/encrypted_data_bag_secret"
  app_configs << Chef::EncryptedDataBagItem.load("rails_apps", dbag_item)
end

app_configs.each do |app|
  
  appname = app['appname']
  
  # Set up directories for each stage
  app['stages'].each do |stage_name, stage_data|
   
    
    deploy_user   = stage_data['deploy_user']
    base_path     = "/home/#{deploy_user}/#{appname}/#{stage_name}"    
    instance_name = [appname, stage_name].join("_")

    # Set up directory and file name info for SSL certs
    ssl_dir        = (stage_data['enable_ssl']) ? "/etc/apache2/ssl/#{appname}/#{stage_name}/" : ""
    ssl_cert_file  = (stage_data['enable_ssl']) ? "#{instance_name}.crt" : ""
    ssl_key_file   = (stage_data['enable_ssl']) ? "#{instance_name}.key" : ""
    ssl_chain_file = (stage_data['enable_ssl']) ? "#{instance_name}-bundle.crt" : ""

    # See the definitions directory for the "app_config" source. It is 
    # a modified version of the "web_app" definition that is included 
    # in Opscode's apache2 cookbook. It uses these values to generate the 
    # config files for the specified site and place them in
    # /etc/apache2/sites-available, optionally running a2ensite 
    # or a2dissite based on the value of the "enable" parameter.
    app_config(instance_name) do
      docroot                   "#{base_path}/current/public"
      rack_env                  stage_name
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

    # If we're using SSL, create the appropriate 
    # directories and files.
    if stage_data['enable_ssl']
   
      # Create the directory
      directory ssl_dir do
        owner "root"
        group "root"
        mode "0755"
        action :create
        recursive true
      end
      
      # Write the file contents
      [[ssl_cert_file,  "ssl_cert_file"], 
       [ssl_key_file,   "ssl_cert_key_file"],
       [ssl_chain_file, "ssl_cert_chain_file"]].each do |ssl_filename, data_key|
      
        template_content = begin
          if stage_data[data_key].instance_of? Array
            stage_data[data_key].join("\n")
          else
            stage_data[data_key]
          end
        end

        template "#{ssl_dir}#{ssl_filename}" do
          source "ssl.erb"
          owner  "root"
          group  "root"
          mode   0600
          variables(:content => template_content)
          notifies :reload, resources(:service => "apache2"), :delayed
        end
      end
    end

  end 
end

# Disable Apache's default site
apache_site "000-default" do
  enable false
end
