class Employment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  attr_accessible :end_date, :start_date, :workload

  validates_presence_of :user, :start_date, :workload
  validates_inclusion_of  :workload, :in => 1..100,
                          :message => I18n.t('.error_outside_1_and_100_percent', scope: [:activerecord, :errors, :models, :employment])

  before_destroy :check_if_last
  before_save :resolve_conflicts
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

  private

  def resolve_conflicts
    employments = user.employments
    employments.find do |other|
      next if self == other

      if other.open_ended? && self.open_ended?
        other.end_date = self.start_date - 1.day
        other.save
      end
    end
  end

  def check_if_last
    errors.add(:base, 'Cannot delete the last employment of the user') if user.employments.length <= 1
    errors.blank?
  end
end
