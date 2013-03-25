class RenameLdapIdToUid < ActiveRecord::Migration
  def up
    rename_column :teams, :ldap_id, :uid
    rename_column :users, :ldap_id, :uid
  end

  def down
    rename_column :teams, :uid, :ldap_id
    rename_column :users, :ldap_id, :uid
  end
end
