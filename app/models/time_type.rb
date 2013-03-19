class TimeType < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  scope :absences, where(is_work:  false)

  default_scope order(:name)

  attr_accessible :is_vacation, :is_work, :name, :treat_as_working_time, :daywise, :timewise

  validates_presence_of :name

  validates_uniqueness_of_without_deleted :name

  def to_s
    name
  end

  def treat_duration_relative_to_daily_working_time?
    daywise == true and treat_as_working_time == true
  end

  def is_vacation?
    is_vacation == true
  end

  def is_work?
    is_work == true
  end

  def kind
    case
    when is_work?
      :work
    when is_vacation?
      :vacation
    else
      :break
    end
  end

  def type_for_entries
    case
    when daywise && timewise
      :both
    when daywise
      :daywise
    when timewise
      :timewise
    end
  end

end
