class Day < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :planned_working_time

  scope :in, lambda { |range| date_range = range.to_range.to_date_range; { conditions: ['(date <= ? AND date >= ?)', date_range.max, date_range.min] } }
end
