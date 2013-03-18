class CreateExceptionDates < ActiveRecord::Migration
  def change
    create_table :exception_dates do |t|
      t.references :recurring_schedule
      t.date :date

      t.timestamps
    end
    add_index :exception_dates, :recurring_schedule_id
  end
end
