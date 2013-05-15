class RemoveRoleFromMemberships < ActiveRecord::Migration
  def up
    remove_column :memberships, :role
  end

  def down
    add_column :memberships, :role, :string
  end
end
