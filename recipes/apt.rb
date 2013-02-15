# to force apt-get update to be run
file "/var/lib/apt/periodic/update-success-stamp" do
  action :delete
end

