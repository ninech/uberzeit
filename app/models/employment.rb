class Employment < ActiveRecord::Base
  belongs_to :user
  attr_accessible :end_time, :start_time, :workload

  def self.default
    Employment.new({
      start_time: Date.today,
      workload: 100
    })
  end
end
