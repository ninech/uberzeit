# == Schema Information
#
# Table name: adjustments
#
#  id           :integer          not null, primary key
#  time_type_id :integer
#  date         :date
#  duration     :integer
#  label        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#  user_id      :integer
#

class Adjustment < ActiveRecord::Base
  acts_as_paranoid

  default_scope order(:date)

  scope :in, lambda { |range| date_range = range.to_range.to_date_range; { conditions: ['(date >= ? AND date <= ?)', date_range.min, date_range.max] } }

  scope :exclude_vacation, joins: :time_type, conditions: ['is_vacation = ?', false]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]

  belongs_to :user
  belongs_to :time_type
  has_one :time_span,
    conditions: proc { {date: self.date }},
    as: :time_spanable,
    dependent: :destroy

  attr_accessible :date, :duration, :label, :user_id, :time_type_id, :user_id, :duration_in_work_days, :duration_in_hours

  validates_presence_of       :user, :time_type, :date, :duration
  validates_numericality_of   :duration
  validates_date              :date

  after_save :update_or_create_time_span

  def self.total_duration
    sum(:duration)
  end

  def duration_in_work_days
    duration && duration.to_work_days
  end

  def duration_in_work_days=(num_work_days)
    self.duration = num_work_days.to_f.work_days
  end

  def duration_in_hours
    duration && UberZeit.duration_in_hhmm(duration)
  end

  def duration_in_hours=(hours)
    self.duration =   if hours.to_s.index(':')
                        UberZeit.hhmm_in_duration(hours)
                      else
                        hours.to_f.hours
                      end
  end

  def to_s
    label
  end

  def update_or_create_time_span
    build_time_span unless time_span
    time_span.duration = duration
    time_span.user = user
    time_span.time_type = time_type
    time_span.save!
  end

end
