actions :create, :drop
default_action :create

attribute :name, kind_of: String, name_attribute: true, default: 'main'
attribute :port, kind_of: Integer, required: true
attribute :max_connections, kind_of: Integer, default: 100

attribute :username, kind_of: String, required: true
attribute :password, kind_of: String, default: nil
