class RenameDurationInDaysToDurationInWorkDays < ActiveRecord::Migration
  def change
    rename_column :time_spans, :duration_days, :duration_in_work_days
  end
end
