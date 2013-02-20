require 'nine/ldap'

def recursive_symbolize_keys! hash
  hash.symbolize_keys!
  hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
end

YAML::ENGINE.yamler = 'syck'
config = YAML.load_file(Rails.root.join('config', 'ldap.yml'))[Rails.env]

recursive_symbolize_keys!(config)

Nine::LDAP::Model::Base.default_connection = Nine::LDAP::Connection.setup(config)
