class SingleEntry < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :end_time, :start_time, :time_type_id

  validates_presence_of :time_type, :time_sheet, :start_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time

  before_validation :round_times

  def duration
    (end_time - start_time).to_i
  end

  def whole_day?
    duration == 86400
  end

  private

  def round_times
    self.start_time = self.start_time.round
    self.end_time = self.end_time.round
  end
end
