class AddColorIndexToTimeTypes < ActiveRecord::Migration
  def up
    add_column :time_types, :color_index, :integer, default: 0
  end

  def down
    remove_column :time_types, :color_index
  end
end
