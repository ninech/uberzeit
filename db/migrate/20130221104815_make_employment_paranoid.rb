class MakeEmploymentParanoid < ActiveRecord::Migration
  def up
    add_column :employments, :deleted_at, :time
  end

  def down
    remove_column :employments, :deleted_at
  end
end
