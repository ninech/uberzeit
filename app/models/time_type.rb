class TimeType < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  scope :absences, where(is_work:  false)

  default_scope order(:name)

  attr_accessible :is_vacation, :is_work, :name, :ignore_in_calculation, :absence

  validates_presence_of :name

  validates_uniqueness_of_without_deleted :name

  def to_s
    name
  end

  def ignore_in_calculation?
    !!ignore_in_calculation
  end

  def is_absence?
    !!absence
  end

  def is_vacation?
    !!is_vacation
  end

  def is_work?
    !!is_work
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
