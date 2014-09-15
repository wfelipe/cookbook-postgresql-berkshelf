#
# Cookbook Name:: postgresql
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

package "postgresql-#{node[:postgresql][:version]}"

service "postgresql" do
  action [ :enable, :start ]
  supports reload: true, status: true, restart: true
end

node[:postgresql][:databases].each do |name, attrs|
  postgresql_instance name do
    attrs.each do |attr,val|
      send(attr.to_sym, val)
    end
  end
end
