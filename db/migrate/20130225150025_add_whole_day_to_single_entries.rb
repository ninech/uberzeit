class AddWholeDayToSingleEntries < ActiveRecord::Migration
  def up
    add_column :single_entries, :whole_day, :boolean, :default => false
  end

  def down
    remove_column :single_entries, :whole_day
  end
end
