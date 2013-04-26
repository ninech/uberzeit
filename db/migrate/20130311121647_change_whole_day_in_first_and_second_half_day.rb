class ChangeWholeDayInFirstAndSecondHalfDay < ActiveRecord::Migration
  def up
    remove_column :entries, :whole_day
    add_column :entries, :first_half_day, :boolean, default: false
    add_column :entries, :second_half_day, :boolean, default: false
  end

  def down
    add_column :entries, :whole_day, :boolean, default: false
    remove_column :entries, :first_half_day
    remove_column :entries, :second_half_day
  end
end
