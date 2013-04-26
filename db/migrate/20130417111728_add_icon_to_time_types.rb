class AddIconToTimeTypes < ActiveRecord::Migration
  def up
    add_column :time_types, :icon, :string
  end

  def down
    remove_column :time_types, :icon
  end
end
