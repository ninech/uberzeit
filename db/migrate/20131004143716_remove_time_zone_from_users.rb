class RemoveTimeZoneFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :time_zone
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
