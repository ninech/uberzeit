class CreateRecurringSchedules < ActiveRecord::Migration
  def change
    create_table :recurring_schedules do |t|
      t.boolean :active, :default => 0
      t.integer :enterable_id
      t.string :enterable_type
      t.string :ends
      t.integer :ends_counter
      t.date :ends_date
      t.string :repeat_interval_type
      t.integer :daily_repeat_interval
      t.integer :weekly_repeat_interval
      t.string :weekly_repeat_weekday
      t.integer :monthly_repeat_interval
      t.string :monthly_repeat_by
      t.integer :yearly_repeat_interval

      t.timestamps
    end
  end
end
