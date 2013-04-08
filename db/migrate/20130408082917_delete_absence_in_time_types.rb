class DeleteAbsenceInTimeTypes < ActiveRecord::Migration
  def up
    remove_column :time_types, :absence
  end

  def down
    add_column :time_types, :absence, :boolean
  end
end
