class MarkDeletedUsersAsDeactivated < ActiveRecord::Migration
  def up
    User.only_deleted.each do |deleted_user|
      deleted_user.recover
      deleted_user.update_attributes(active: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
