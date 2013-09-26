class SetDefaultTrueInAbsences < ActiveRecord::Migration
  def up
    change_column :absences, :first_half_day, :boolean, default: true
    change_column :absences, :second_half_day, :boolean, default: true
  end

  def down
    change_column :absences, :first_half_day, :boolean, default: false
    change_column :absences, :second_half_day, :boolean, default: false
  end
end
