# == Schema Information
#
# Table name: days
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  date                 :date
#  planned_working_time :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Day < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :planned_working_time

  validates_presence_of :user, :planned_working_time, :date

  scope :in, lambda { |range| date_range = range.to_range.to_date_range; { conditions: ['(date <= ? AND date >= ?)', date_range.max, date_range.min] } }

  def self.create_or_regenerate_days_for_user_and_range!(user, range)
    GeneratePlannedWorkingTimeForUserAndDates.new(user, range).run
  end

  def self.create_or_regenerate_days_for_user_and_year!(user, year)
    year_as_range = Date.civil(year, 1, 1)..Date.civil(year, 12, 31)
    self.create_or_regenerate_days_for_user_and_range!(user, year_as_range)
  end

  def regenerate!
    GeneratePlannedWorkingTimeForUserAndDates.new(user, date).run
  end
end
