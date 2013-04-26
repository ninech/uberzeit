class ChangeRecurringSchedule < ActiveRecord::Migration
  def up
    remove_column :recurring_schedules, :daily_repeat_interval
    remove_column :recurring_schedules, :monthly_repeat_interval
    remove_column :recurring_schedules, :yearly_repeat_interval
    remove_column :recurring_schedules, :weekly_repeat_weekday
    remove_column :recurring_schedules, :monthly_repeat_by
    remove_column :recurring_schedules, :repeat_interval_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
