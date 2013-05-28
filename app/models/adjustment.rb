class Adjustment < ActiveRecord::Base
  acts_as_paranoid

  default_scope includes(:time_sheet => :user).order('users.name, users.given_name, adjustments.date')

  belongs_to :time_sheet
  belongs_to :time_type

  attr_accessible :date, :duration, :label, :time_sheet_id, :time_type_id, :user_id, :duration_in_work_days, :duration_in_hours

  validates_presence_of       :time_sheet, :time_type, :date, :duration
  validates_numericality_of   :duration
  validates_date              :date

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
    duration && duration.to_hours
  end

  def duration_in_hours=(num_hours)
    self.duration = num_hours.to_f.hours
  end

end
