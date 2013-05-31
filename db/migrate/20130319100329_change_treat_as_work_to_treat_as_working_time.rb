class ChangeTreatAsWorkToTreatAsWorkingTime < ActiveRecord::Migration
  def up
    rename_column :time_types, :treat_as_work, :treat_as_working_time
  end

  def down
    rename_column :time_types, :treat_as_working_time, :treat_as_work
  end
end
