class Adjustment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type

  attr_accessible :date, :duration, :label, :time_sheet_id, :time_type_id

  validates_presence_of       :time_sheet, :time_type, :date, :duration
  validates_numericality_of   :duration
  validates_date              :date

end
