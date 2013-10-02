class RemoveObsoleteStuffInAbsenceSchedules < ActiveRecord::Migration
  def up
    remove_column :absence_schedules, :ends
    remove_column :absence_schedules, :ends_counter
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
