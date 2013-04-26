class RenameDateEntriesToAbsences < ActiveRecord::Migration
  def up
    rename_table :date_entries, :absences
  end

  def down
    rename_table :absences, :date_entries
  end
end
