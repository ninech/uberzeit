class MakeRecurringEntryParanoid < ActiveRecord::Migration
  def up
    add_column :recurring_entries, :deleted_at, :datetime
  end

  def down
    remove_column :recurring_entries, :deleted_at
  end
end
