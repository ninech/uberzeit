class TimeType < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  default_scope order(:name)

  attr_accessible :is_vacation, :is_work, :name, :treat_as_work, :daywise, :timewise

  validates_presence_of :name

  validates_uniqueness_of_without_deleted :name

  def to_s
    name
  end

end
