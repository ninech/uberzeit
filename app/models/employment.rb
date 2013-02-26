class Employment < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :user
  attr_accessible :end_time, :start_time, :workload
  
  validates_presence_of :user, :start_time, :workload

  scope :when, lambda { |date| { conditions: ['? >= start_time AND (? <= end_time OR end_time IS NULL)', date.midnight, date.midnight] } }
  scope :between, lambda { |starts, ends| { conditions: ['start_time < ? AND (end_time > ? OR end_time IS NULL)', ends, starts] } }
  
  def self.default
    Employment.new({
      start_time: Time.zone.now.beginning_of_year,
      workload: 100
    })
  end
end
