class CreateRecurringEntries < ActiveRecord::Migration
  def change
    create_table :recurring_entries do |t|
      t.references :time_sheet
      t.references :time_type
      t.text :schedule_hash

      t.timestamps
    end
    add_index :recurring_entries, :time_sheet_id
    add_index :recurring_entries, :time_type_id
  end
end
