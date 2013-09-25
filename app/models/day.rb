class Day < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :planned_working_time
end
