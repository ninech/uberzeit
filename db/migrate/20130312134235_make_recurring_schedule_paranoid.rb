class MakeRecurringScheduleParanoid < ActiveRecord::Migration
  def up
    add_column :recurring_schedules, :deleted_at, :datetime
  end

  def down
    remove_column :recurring_schedules, :deleted_at
  end
end
