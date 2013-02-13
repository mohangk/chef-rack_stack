name              "chef_rack-stack"
maintainer        "Mohan Krishnan, Abhaya Shenoy, Winston Teo"
maintainer_email  "mohangk@gmail.com, abhayashenoy@gmail.com, winstonyw@gmail.com"
license           "Apache 2.0"
description       "Gets your Rails app up and running"
version           "0.0.1"
recipe            "default", "Get your Rails freak on"

%w{ ubuntu debian }.each do |os|
  supports os
end

#apt is required by the postgresql recipe to allow for addition of the pitti repo
%w{apt xml git ruby application_ruby postgresql nodejs imagemagick user}.each do |cb|
  depends cb
end
