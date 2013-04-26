class MakeSingleEntryParanoid < ActiveRecord::Migration
  def up
    add_column :single_entries, :deleted_at, :datetime
  end

  def down
    remove_column :single_entries, :deleted_at
  end
end
