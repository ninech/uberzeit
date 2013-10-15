# == Schema Information
#
# Table name: absence_schedules
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(FALSE)
#  absence_id             :integer
#  ends_date              :date
#  weekly_repeat_interval :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

class AbsenceSchedule < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :absence, touch: true

  attr_accessible :active, :ends_date, :absence, :weekly_repeat_interval
  validates_numericality_of :weekly_repeat_interval, greater_than: 0, if: :active?
  validates_presence_of :weekly_repeat_interval, if: :active?
  validates_date :ends_date, on_or_after: lambda { |schedule| schedule.absence.end_date }, if: :has_absence_and_schedule_active?

  validates_uniqueness_of :absence_id

  def has_absence_and_schedule_active?
    !absence.nil? && active?
  end

  def active?
    !!active
  end

  def recurring_start_date
    absence.start_date
  end

  def recurring_end_date
    # make sure the recurring schedule end date is at least the end date of the associated entry
    absence.end_date >= ends_date ? absence.end_date : ends_date
  end

  def recurring_date_range
    (recurring_start_date..recurring_end_date)
  end

  def interval
    weekly_repeat_interval.weeks
  end

  def occurrences(date_or_range = recurring_date_range)
    find_in_date_range = date_or_range.to_range.to_date_range

    occurrences = []

    date_min = recurring_date_range.min
    date_max = [recurring_date_range.max, find_in_date_range.max].min
    each_occurrence_between(date_min, date_max) do |date|
      start_date = date
      end_date = start_date + absence.num_days
      range = start_date..end_date
      next unless range.intersects_with_duration?(find_in_date_range)

      occurrences << range
    end

    occurrences
  end

  def occurring?(date_or_range)
    occurrences(date_or_range).any?
  end

  private
  def each_occurrence_between(date, date_end, &block)
    begin
      yield(date)
    end while (date += interval) <= date_end
  end
end
