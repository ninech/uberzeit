class CreateTimers < ActiveRecord::Migration
  def change
    create_table :timers do |t|
      t.references :time_sheet
      t.references :time_type
      t.datetime :start_time

      t.timestamps
    end
    add_index :timers, :time_sheet_id
    add_index :timers, :time_type_id
  end
end
