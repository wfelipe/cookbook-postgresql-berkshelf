require 'rubygems'
require 'json'
require 'chef/encrypted_data_bag_item'
 
secret = Chef::EncryptedDataBagItem.load_secret('data_bag_key')
data = JSON.parse(File.read(ARGV[0]))
encrypted_data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(data, secret)
 
puts JSON.pretty_generate(encrypted_data)
