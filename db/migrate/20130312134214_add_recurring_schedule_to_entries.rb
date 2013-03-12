class AddRecurringScheduleToEntries < ActiveRecord::Migration
  def up
    change_table :date_entries do |t|
      t.references :recurring_schedule
    end
    change_table :time_entries do |t|
      t.references :recurring_schedule
    end
  end

  def down
    remove_column :time_entries, :recurring_schedule
    remove_column :date_entries, :recurring_schedule
  end
end
