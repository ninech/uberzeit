class AddCalculationFactorToTimeTypes < ActiveRecord::Migration
  def change
    change_table :time_types do |t|
      t.float "calculation_factor", :default => 1
    end
  end
end
