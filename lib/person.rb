class Person < Nine::LDAP::Model::Base
  ldap_mapping dn_attribute: 'uid'
  ldap_attr(:cn, :gidnumber, :homedirectory, :sn, :uid,
    :uidnumber, :birthdate, :displayname, :employeenumber, :gecos,
    :givenname, :jpegphoto, :l, :loginshell, :mail, :mobile, :postalcode,
    :shadowmax, :shadowwarning, :st, :telephonenumber, :userpassword)
  ldap_attr_many :objectclass, :employeetype
  ldap_referenced_by :departments

  default_sort_with do |objects|
    objects.sort! do |a,b|
      a.sn <=> b.sn
    end
  end
end
