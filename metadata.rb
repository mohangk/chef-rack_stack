maintainer        "Newcontext, PLC."
maintainer_email  "amerson@newcontext.com / mohan@newcontext.com"
license           "Apache 2.0"
description       "Gets your Rails app up and running"
version           "0.0.1"
recipe            "default", "Get your Rails freak on"

%w{ ubuntu debian }.each do |os|
  supports os
end
