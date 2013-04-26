class AddTypeToSingleEntries < ActiveRecord::Migration
  def up
    add_column :single_entries, :type, :string
  end

  def down
    remove_column :single_entries, :type
  end
end
