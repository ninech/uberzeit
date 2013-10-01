class AddCreditedDurationToTimeSpans < ActiveRecord::Migration
  def change
    add_column :time_spans, :credited_duration, :integer
    add_column :time_spans, :credited_duration_in_work_days, :float
  end
end
