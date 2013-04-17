class TimeType < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  scope :absence,   where(is_work: false)
  scope :work,      where(is_work: true)
  scope :vacation,  where(is_vacation: true)

  default_scope order(:name)

  attr_accessible :is_vacation, :is_work, :name, :absence, :calculation_factor, :icon
  validates_presence_of :name, :calculation_factor
  validates_numericality_of :calculation_factor, greater_than_or_equal_to: 0

  validates_uniqueness_of_without_deleted :name

  def to_s
    name
  end

  def is_absence?
    not is_work?
  end

  def is_vacation?
    !!is_vacation
  end

  def is_work?
    !!is_work
  end

  def kind
    if is_absence?
      :absence
    else
      :work
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
