class MakeTimeTypeParanoid < ActiveRecord::Migration
  def up
    add_column :time_types, :deleted_at, :datetime
  end

  def down
    remove_column :time_types, :deleted_at
  end
end
