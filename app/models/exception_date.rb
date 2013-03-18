class ExceptionDate < ActiveRecord::Base
  belongs_to :recurring_schedule
  attr_accessible :date
end
