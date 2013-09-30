# == Schema Information
#
# Table name: time_spans
#
#  id                    :integer          not null, primary key
#  date                  :date
#  duration              :integer
#  duration_in_work_days :float
#  duration_bonus        :integer
#  user_id               :integer
#  time_type_id          :integer
#  time_spanable_id      :integer
#  time_spanable_type    :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class TimeSpan < ActiveRecord::Base

  belongs_to :user
  belongs_to :time_type
  belongs_to :time_spanable, polymorphic: true

  attr_accessible :date, :duration, :duration_bonus, :duration_days

  validates_presence_of :date, :duration, :duration_in_work_days,
                        :user_id, :time_type_id, :time_spanable_id, :time_spanable_type

  def duration=(value)
    write_attribute :duration_in_work_days, value.to_work_days
    super
  end

  def duration_in_work_days=(value)
    write_attribute :duration, value.work_days
    super
  end

end
