class Department < Nine::LDAP::Model::Base
  ldap_mapping
  ldap_attr :cn, :description
  ldap_attr_many :uniquemember, :owner, :objectclass
  ldap_references_many :people
  ldap_references_many :managers, foreign_key: :owner, class_name: 'Person'
end
