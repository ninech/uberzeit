class Employment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  attr_accessible :end_date, :start_date, :workload

  validates_presence_of :user, :start_date, :workload
  validates_inclusion_of :workload, :in => 1..100, :message => "must be within 1 and 100 percent"

  before_destroy :check_if_last
  before_save :resolve_conflicts
  before_validation :set_default_values, unless: :persisted?

  default_scope order(:start_date)

  # Ensure in scopes that we use dates and not times, because a '2012-01-06 00:00:00 GMT+1'.to_time results
  # in '2012-01-05 23:00:00 UTC' which itself shifts the day.
  scope :when, lambda { |date|
    raise "Must be a date" unless date.kind_of?(Date)
    { conditions: ['? >= start_date AND (? < end_date OR end_date IS NULL)', date, date ] }
  }

  scope :between, lambda { |starts, ends|
    raise "Must be a date-range" unless starts.kind_of?(Date) and ends.kind_of?(Date)
    { conditions: ['start_date < ? AND (end_date > ? OR end_date IS NULL)', ends, starts] }
  }


  def set_default_values
    self.start_date ||= Time.zone.now.beginning_of_year.to_date
    self.workload ||= 100
  end

  def self.on(date)
    self.when(date).first
  end

  def open_ended?
    end_date.nil?
  end

  private

  def resolve_conflicts
    employments = user.employments
    employments.find do |other|
      next if self == other

      if other.open_ended? && self.open_ended?
        other.end_date = self.start_date
        other.save
      end
    end
  end

  def check_if_last
    errors.add(:base, 'Cannot delete the last employment of the user') if user.employments.length <= 1
    errors.blank?
  end
end
