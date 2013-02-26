class AddTimeZoneToUsers < ActiveRecord::Migration
  def up
    add_column :users, :time_zone, :string
  end

  def down
    remove_column :users, :time_zone
  end
end
