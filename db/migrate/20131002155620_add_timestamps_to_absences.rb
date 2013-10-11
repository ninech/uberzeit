class AddTimestampsToAbsences < ActiveRecord::Migration
  def change
    change_table :absences do |t|
      t.timestamps
    end
  end
end
