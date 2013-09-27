# == Schema Information
#
# Table name: time_types
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  is_work                  :boolean          default(FALSE)
#  is_vacation              :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  deleted_at               :datetime
#  icon                     :string(255)
#  color_index              :integer          default(0)
#  exclude_from_calculation :boolean          default(FALSE)
#  bonus_calculator         :string(255)
#

class TimeType < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  scope :absence,   where(is_work: false)
  scope :work,      where(is_work: true)

  default_scope order(:name)

  attr_accessible :is_vacation, :is_work, :name, :absence
  attr_accessible :bonus_calculator, :exclude_from_calculation, :icon, :color_index

  validates_presence_of :name
  validates_inclusion_of :exclude_from_calculation, in: [true, false]
  validates_inclusion_of :bonus_calculator, in: UberZeit::BonusCalculators.available_calculators.keys, allow_blank: true

  has_many :time_entries
  has_many :time_spans

  validates_uniqueness_of_without_deleted :name

  after_save :update_time_spans, if: :bonus_calculator_changed?

  def self.vacation
    # there can be only one vacation time type
    scoped.where(is_vacation: true).first
  end

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

  def exclude_from_calculation?
    !!exclude_from_calculation
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

  def update_time_spans
    time_entries.reload.each do |time_entry|
      time_entry.update_or_create_time_span
    end
  end

end
