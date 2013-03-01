class RecurringEntry < ActiveRecord::Base
  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :schedule_hash
end
