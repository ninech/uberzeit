class ChangeTimeTypes < ActiveRecord::Migration
  def up
    change_table :time_types do |t|
      t.remove :timewise
      t.rename :daywise, :absence
      t.remove :treat_as_working_time
      t.boolean :ignore_in_calculation, default: false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
