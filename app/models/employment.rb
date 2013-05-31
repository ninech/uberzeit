class Employment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  attr_accessible :end_date, :start_date, :workload, :user

  validates_presence_of :user, :start_date, :workload
  validates_inclusion_of  :workload, :in => 1..100,
                          :message => I18n.t('.error_outside_1_and_100_percent', scope: [:activerecord, :errors, :models, :employment])

  validates_datetime :start_date
  validates_datetime :end_date, on_or_after: :start_date, unless: :open_ended?

  before_destroy :check_if_last

  before_validation :ensure_no_other_entry_is_open_ended, if: :open_ended?
  before_validation :ensure_no_overlaps, unless: :open_ended?

  before_validation :set_default_values, unless: :persisted?

  default_scope order(:start_date)

  scope :when, lambda { |date|
    raise "Must be a date" unless date.kind_of?(Date)
    { conditions: ['? >= start_date AND (? <= end_date OR end_date IS NULL)', date, date ] }
  }

  scope :between, lambda { |range|
    date_range = range.to_date_range;
    { conditions: ['start_date <= ? AND (end_date >= ? OR end_date IS NULL)', date_range.max, date_range.min] }
  }

  def set_default_values
    self.start_date ||= Time.current.beginning_of_year.to_date
    self.workload ||= 100
  end

  def self.on(date)
    self.when(date).first
  end

  def open_ended?
    end_date.nil?
  end

  def on_date?(date)
    start_date <= date and end_date.nil? || date <= end_date
  end

  def range
    (start_date..end_date)
  end

  private

  def other_employments
    user.employments.select{ |other| other != self && other.persisted? }
  end

  def ensure_no_other_entry_is_open_ended
    any_other_open_ended = other_employments.any? { |other| other.open_ended? }
    errors.add(:base, :there_is_another_open_ended_entry) if any_other_open_ended
    not any_other_open_ended
  end

  def ensure_no_overlaps
    any_overlaps = other_employments.reject{ |other| other.open_ended? }.any? { |other| other.range.intersects_with_duration?(self.range) }
    errors.add(:base, :overlaps_with_another_entry) if any_overlaps
    not any_overlaps
  end

  def check_if_last
    errors.add(:base, :cannot_delete_single_employment) if user.employments.length <= 1
    errors.blank?
  end
end
