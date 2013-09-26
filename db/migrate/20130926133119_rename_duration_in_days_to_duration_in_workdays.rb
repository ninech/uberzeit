class RenameDurationInDaysToDurationInWorkdays < ActiveRecord::Migration
  def change
    rename_column :time_spans, :duration_days, :duration_in_workdays
  end
end
