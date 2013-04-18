class AddExcludeFromCalculationToTimeTypes < ActiveRecord::Migration
  def up
    add_column :time_types, :exclude_from_calculation, :boolean, default: false
  end

  def down
    remove_column :time_types, :exclude_from_calculation, :boolean
  end
end
