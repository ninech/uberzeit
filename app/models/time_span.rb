# == Schema Information
#
# Table name: time_spans
#
#  id                    :integer          not null, primary key
#  date                  :date
#  duration              :integer
#  duration_in_work_days :float
#  duration_bonus        :integer
#  user_id               :integer
#  time_type_id          :integer
#  time_spanable_id      :integer
#  time_spanable_type    :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
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
  scope :date_between,      ->(date_range) { where('date BETWEEN ? AND ?', date_range.min, date_range.max) }

  scope :for_team,          ->(team) { where(user_id: User.in_teams(team)) }

  scope :effective,         joins(:time_type).where('NOT (time_spanable_type = ? AND time_types.is_vacation = ?)', Adjustment.model_name, true)
  scope :absences,          joins(:time_type).where(time_types: {is_work: false})

  scope :eligible_for_summarizing_absences, absences.effective

  def self.duration_in_work_day_sum_per_user_and_time_type
    group('time_spans.user_id').group('time_spans.time_type_id').sum(:duration_in_work_days)
  end

  def self.duration_in_work_day_sum_per_time_type
    group('time_spans.time_type_id').sum(:duration_in_work_days)
  end

  #  @total = TimeSpan
  #    .joins(:time_type)
  #    .joins(:user => :memberships)
  #    .where(memberships: {team_id: @team})
  #    .where(time_types: {is_work: false})
  #    .where('NOT (time_spanable_type = ? AND time_types.is_vacation = ?)', Adjustment.model_name, true)
  #    .where('date >= ?', "#{@year}-01-01")
  #    .where('date <= ?', "#{@year}-12-31")
  #    .group(:time_type_id)
  #    .sum(:duration_in_work_days)

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
