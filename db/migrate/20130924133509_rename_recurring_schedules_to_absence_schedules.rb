class RenameRecurringSchedulesToAbsenceSchedules < ActiveRecord::Migration
  def up
    rename_table :recurring_schedules, :absence_schedules
    remove_column :absence_schedules, :enterable_type
    rename_column :absence_schedules, :enterable_id, :absence_id
    add_index :absence_schedules, :absence_id
  end

  def down
    remove_index :absence_schedules, :absence_id
    add_column :absence_schedules, :enterable_type, :string
    rename_column :absence_schedules, :absence_id, :enterable_id
    rename_table :absence_schedules, :recurring_schedules
  end
end
