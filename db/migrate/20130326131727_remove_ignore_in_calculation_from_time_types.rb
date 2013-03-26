class RemoveIgnoreInCalculationFromTimeTypes < ActiveRecord::Migration
  def up
    remove_column :time_types, :ignore_in_calculation
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
