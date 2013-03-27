class ExceptionDate < ActiveRecord::Base
  belongs_to :recurring_schedule
  attr_accessible :date

  scope :in, lambda { |range| date_range = range.to_range.to_date_range; { conditions: ['(date >= ? AND date <= ?)', date_range.min, date_range.max] } }

end
