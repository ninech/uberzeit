class MakeUserParanoid < ActiveRecord::Migration
  def up
    add_column :users, :deleted_at, :time
  end

  def down
    remove_column :users, :deleted_at
  end
end
