name              "chef_rack-stack"
maintainer        "Mohan Krishnan"
maintainer_email  "mohan@neo.com"
license           "Apache 2.0"
description       "Gets your Rails app up and running"
version           "0.0.1"
recipe            "default", "Get your Rails freak on"

%w{ ubuntu debian }.each do |os|
  supports os
end

%w{xml git ruby application_ruby postgresql nodejs memcached imagemagick user}.each do |cb|
  depends cb
end
