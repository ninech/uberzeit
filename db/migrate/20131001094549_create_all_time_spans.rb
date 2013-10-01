class CreateAllTimeSpans < ActiveRecord::Migration
  def up
    say_with_time "Creating or updating TimeSpans of Absences" do
      Absence.all.each(&:update_or_create_time_span)
    end
    say_with_time "Creating or updating TimeSpans of TimeEntries" do
      TimeEntry.all.each(&:update_or_create_time_span)
    end
    say_with_time "Creating or updating TimeSpans of Adjustment" do
      Adjustment.all.each(&:update_or_create_time_span)
    end
  end

  def down
    TimeSpan.delete_all
  end
end
