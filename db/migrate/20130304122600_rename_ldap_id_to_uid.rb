class RenameLdapIdToUid < ActiveRecord::Migration
  def up
    rename_column :users, :ldap_id, :uid
  end

  def down
    rename_column :users, :uid, :ldap_id
  end
end
