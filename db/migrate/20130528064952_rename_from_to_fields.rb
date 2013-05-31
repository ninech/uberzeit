class RenameFromToFields < ActiveRecord::Migration
  def up
    rename_column :time_entries, :start_time, :starts
    rename_column :time_entries, :end_time, :ends
  end

  def down
    rename_column :time_entries, :starts, :start_time
    rename_column :time_entries, :ends, :ends
  end
end
