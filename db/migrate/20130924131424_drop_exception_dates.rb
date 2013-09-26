class DropExceptionDates < ActiveRecord::Migration
  def up
    drop_table :exception_dates
  end

  def down
    create_table :exception_dates do |t|
      t.integer :recurring_schedule_id
      t.date :date
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :exception_dates, [:recurring_schedule_id]
  end
end
