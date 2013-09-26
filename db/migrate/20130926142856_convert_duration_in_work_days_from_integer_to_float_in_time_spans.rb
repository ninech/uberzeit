class ConvertDurationInWorkDaysFromIntegerToFloatInTimeSpans < ActiveRecord::Migration
  def up
    change_column :time_spans, :duration_in_work_days, :float
  end
  def down
    change_column :time_spans, :duration_in_work_days, :integer
  end
end
