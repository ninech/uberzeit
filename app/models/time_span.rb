# == Schema Information
#
# Table name: time_spans
#
#  id                             :integer          not null, primary key
#  date                           :date
#  duration                       :integer
#  duration_in_work_days          :float
#  duration_bonus                 :integer
#  user_id                        :integer
#  time_type_id                   :integer
#  time_spanable_id               :integer
#  time_spanable_type             :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  credited_duration              :integer
#  credited_duration_in_work_days :float
#

class TimeSpan < ActiveRecord::Base

  belongs_to :user
  belongs_to :time_type
  belongs_to :time_spanable, polymorphic: true

  attr_accessible :date, :duration, :duration_bonus, :duration_days

  validates_presence_of :date,
                        :duration, :duration_in_work_days,
                        :credited_duration, :credited_duration_in_work_days,
                        :user_id, :time_type_id, :time_spanable_id, :time_spanable_type

  scope :in_year,           ->(year) { date_between UberZeit.year_as_range(year) }
  scope :in_year_and_month, ->(year, month) { date_between UberZeit.month_as_range(year, month) }
  scope :date_between,      ->(date_range) do
    if date_range.respond_to?(:min)
      where('date BETWEEN ? AND ?', date_range.min, date_range.max)
    else
      where('date = ?', date_range)
    end
  end

  scope :for_team,          ->(team) { where(user_id: User.in_teams(team)) }
  scope :for_user,          ->(user) { where(user_id: user) }

  scope :exclude_vacation_adjustments,      joins(:time_type)
                                              .where('NOT (time_spanable_type = ? AND time_types.is_vacation = ?)', Adjustment.model_name, true)

  scope :absences,                 where(time_spanable_type: %w[Absence Adjustment])
                                     .exclude_vacation_adjustments

  scope :working_time,             joins(:time_type)
                                     .where(time_types: {exclude_from_calculation: false})

  scope :effective_working_time,    where(time_spanable_type: TimeEntry.model_name)
                                     .joins(:time_type)
                                     .where(time_types: {is_work: true})

  scope :adjustments,               joins(:time_type)
                                      .where(time_spanable_type: Adjustment.model_name)
                                      .exclude_vacation_adjustments

  def self.duration_in_work_day_sum_per_user_and_time_type
    group(:user_id).group(:time_type_id).sum(:duration_in_work_days)
  end

  def self.duration_in_work_day_sum_per_time_type
    group(:time_type_id).sum(:duration_in_work_days)
  end

  def self.duration_sum
    sum(:duration)
  end

  def self.duration_sum_per_time_type
    group(:time_type_id).sum(:duration)
  end

  def self.credited_duration_sum
    sum(:credited_duration)
  end

  def self.credited_duration_sum_per_time_type
    group(:time_type_id).sum(:credited_duration)
  end

  def self.credited_duration_in_work_days_sum
    sum(:credited_duration_in_work_days)
  end

  def self.credited_duration_in_work_days_sum_per_time_type
    group(:time_type_id).sum(:credited_duration_in_work_days)
  end


  def duration=(value)
    write_attribute :duration_in_work_days, value.to_work_days
    super
  end

  def duration_in_work_days=(value)
    write_attribute :duration, value.work_days
    super
  end

  def credited_duration=(value)
    write_attribute :credited_duration_in_work_days, value.to_work_days
    super
  end

  def credited_duration_in_work_days=(value)
    write_attribute :credited_duration, value.work_days
    super
  end

end
