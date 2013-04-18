class RemoveCalculationFactorInTimeTypes < ActiveRecord::Migration
  def up
    remove_column :time_types, :calculation_factor
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
