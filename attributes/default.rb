# base configuration
default[:postgresql][:version] = 9.1
default[:postgresql][:etc_dir] = "/etc/postgresql"
default[:postgresql][:encrypted_data_bag] = false

default[:postgresql][:databases] = Mash.new
