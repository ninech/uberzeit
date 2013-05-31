class RenameSingleEntriesToEntries < ActiveRecord::Migration
  def up
    rename_table :single_entries, :entries
  end

  def down
    rename_table :entries, :single_entries
  end
end
