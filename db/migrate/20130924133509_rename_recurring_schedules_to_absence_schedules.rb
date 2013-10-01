class RenameRecurringSchedulesToAbsenceSchedules < ActiveRecord::Migration
  def up
    rename_table :recurring_schedules, :absence_schedules
    AbsenceSchedule.delete_all!(enterable_type: 'TimeEntry')
    remove_column :absence_schedules, :enterable_type
    rename_column :absence_schedules, :enterable_id, :absence_id
    add_index :absence_schedules, :absence_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
