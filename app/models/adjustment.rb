class Adjustment < ActiveRecord::Base
  acts_as_paranoid

  default_scope order(:date)

  scope :in, lambda { |range| date_range = range.to_range.to_date_range; { conditions: ['(date >= ? AND date <= ?)', date_range.min, date_range.max] } }

  scope :exclude_vacation, joins: :time_type, conditions: ['is_vacation = ?', false]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]

  belongs_to :time_sheet
  belongs_to :time_type

  attr_accessible :date, :duration, :label, :time_sheet_id, :time_type_id, :user_id, :duration_in_work_days, :duration_in_hours

  validates_presence_of       :time_sheet, :time_type, :date, :duration
  validates_numericality_of   :duration
  validates_date              :date

  def self.total_duration
    sum(:duration)
  end

  def user_id=(user_id)
    self.time_sheet = User.find(user_id).current_time_sheet
  end

  def user_id
    time_sheet && time_sheet.user && time_sheet.user.id
  end

  def user
    time_sheet && time_sheet.user
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

end
