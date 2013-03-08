class AddDateToSingleEntries < ActiveRecord::Migration
  def up
    change_table :single_entries do |t|
      t.date :start_date
      t.date :end_date
    end
  end

  def down
    remove_column :single_entries, :start_date
    remove_column :single_entries, :end_date
  end
end
