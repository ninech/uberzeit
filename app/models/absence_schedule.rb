# == Schema Information
#
# Table name: absence_schedules
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(FALSE)
#  absence_id             :integer
#  ends                   :string(255)
#  ends_counter           :integer
#  ends_date              :date
#  weekly_repeat_interval :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

class AbsenceSchedule < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :absence

  attr_accessible :active, :ends, :ends_counter, :ends_date, :absence, :weekly_repeat_interval

  ENDING_CONDITIONS = %w(counter date)

  validates_inclusion_of :ends, in: ENDING_CONDITIONS, if: :active?

  validates_numericality_of :weekly_repeat_interval, greater_than: 0, if: :active?
  validates_numericality_of :ends_counter, greater_than: 0, if: lambda { active? && ends_on_counter? }

  validates_presence_of :weekly_repeat_interval, if: :active?

  validates_date :ends_date, on_or_after: lambda { |rs| rs.absence.end_date }, if: lambda { active? && ends_on_date? }

  validates_uniqueness_of :absence_id

  def active?
    !!active
  end

  def ends_on_date?
    ends == 'date'
  end

  def ends_on_counter?
    ends == 'counter'
  end

  def recurring_start_date
    absence.start_date
  end

  def recurring_end_date
    if ends_on_counter?
      recurring_start_date + interval.to_days * (ends_counter - 1)
    elsif ends_on_date?
      # make sure the recurring schedule end date is at least the end date of the associated entry
      absence.end_date >= ends_date ? absence.end_date : ends_date
    else
      raise "No valid end condition for recurring schedule"
    end
  end

  def recurring_date_range
    (recurring_start_date..recurring_end_date)
  end

  def interval
    weekly_repeat_interval.weeks
  end

  def occurrences(date_or_range)
    find_in_date_range = date_or_range.to_range.to_date_range

    occurrences = []

    date_min = recurring_date_range.min
    date_max = [recurring_date_range.max, find_in_date_range.max].min
    each_occurrence_between(date_min, date_max) do |date|
      start_date = date
      end_date = start_date + absence.num_days
      next unless (start_date..end_date).intersects_with_duration?(find_in_date_range)

      occurrences << start_date
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
