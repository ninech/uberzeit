class MakeAdjustmentParanoid < ActiveRecord::Migration
  def up
    add_column :adjustments, :deleted_at, :datetime
  end

  def down
    remove_column :adjustments, :deleted_at
  end
end
