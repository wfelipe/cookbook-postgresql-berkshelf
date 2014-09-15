action :create do
  name = new_resource.name
  etc_dir = "#{node[:postgresql][:etc_dir]}/#{node[:postgresql][:version]}/#{name}"

  service "postgresql-#{name}" do
    init_command "pg_ctlcluster #{node[:postgresql][:version]} #{name}"
  end

  execute "create cluster #{name}" do
    command "pg_createcluster -p #{new_resource.port} #{node[:postgresql][:version]} #{name}"
    creates etc_dir
    notifies :start, "service[postgresql-#{name}]", :immediate
  end

  template "#{etc_dir}/postgresql.conf" do
    source "postgresql.conf.erb"
    owner 'postgres'
    group 'postgres'
    mode 0640

    notifies :restart, "service[postgresql-#{name}]", :immediate
    variables resource: new_resource, cluster_name: name
  end

  password = if node[:postgresql][:encrypted_data_bag]
               data_bag_item = Chef::EncryptedDataBagItem.load("postgresql", new_resource.username)
               # if no data bag item found, try node attribute
               data_bag_item['password']
             else
               new_resource.password
             end

  template "#{etc_dir}/pg_hba.conf" do
    source "pg_hba.conf.erb"
    owner 'postgres'
    group 'postgres'
    mode 0640

    notifies :reload, "service[postgresql-#{name}]", :immediate
    variables username: new_resource.username, password: password
    # if password is nil, do not set it
    not_if password.nil?
  end

  cluster = "#{node[:postgresql][:version]}/#{name}"
  execute "create user #{new_resource.username} on cluster #{name}" do
    command "echo \"CREATE ROLE #{new_resource.username} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN; ALTER ROLE #{new_resource.username} ENCRYPTED PASSWORD '#{new_resource.password}';\" | psql --cluster #{cluster}"

    user 'postgres'
    group 'postgres'
  end
end

action :drop do
  name = new_resource.name
  etc_dir = "#{node[:postgresql][:etc_dir]}/#{node[:postgresql][:version]}/#{name}"

  execute "drop cluster #{name}" do
    command "pg_dropcluster --stop #{node[:postgresql][:version]} #{name}"
    only_if { ::File.exists?(etc_dir) }
  end
end
