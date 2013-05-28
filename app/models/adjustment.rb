class Adjustment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type

  attr_accessible :date, :duration, :label, :time_sheet_id, :time_type_id, :user_id

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
end
