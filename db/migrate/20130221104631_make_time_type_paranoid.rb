class MakeTimeTypeParanoid < ActiveRecord::Migration
  def up
    add_column :time_types, :deleted_at, :time
  end

  def down
    remove_column :time_types, :deleted_at
  end
end
