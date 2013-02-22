class CreateSingleEntries < ActiveRecord::Migration
  def change
    create_table :single_entries do |t|
      t.references :time_sheet
      t.datetime :start_time
      t.datetime :end_time
      t.references :time_type

      t.timestamps
    end
    add_index :single_entries, :time_sheet_id
    add_index :single_entries, :time_type_id
  end
end
