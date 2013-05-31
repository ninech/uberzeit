class SplitEntry < ActiveRecord::Migration
  def up
    drop_table :entries

    create_table :date_entries do |t|
      t.integer  :time_sheet_id
      t.integer  :time_type_id
      t.date     :start_date
      t.date     :end_date
      t.boolean  :first_half_day,  :default => false
      t.boolean  :second_half_day, :default => false
      t.datetime :deleted_at
      t.timestamp
    end

    add_index :date_entries, :time_sheet_id
    add_index :date_entries, :time_type_id

    create_table :time_entries do |t|
      t.integer  :time_sheet_id
      t.integer  :time_type_id
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :deleted_at
      t.timestamp
    end

    add_index :time_entries, :time_sheet_id
    add_index :time_entries, :time_type_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
