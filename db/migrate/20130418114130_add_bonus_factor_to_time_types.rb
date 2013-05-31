class AddBonusFactorToTimeTypes < ActiveRecord::Migration
  def up
    add_column :time_types, :bonus_factor, :float, default: 0.0
  end

  def down
    remove_column :time_types, :bonus_factor, :float
  end
end
