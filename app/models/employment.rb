class Employment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  attr_accessible :end_date, :start_date, :workload
  
  validates_presence_of :user, :start_date, :workload
  validates_inclusion_of :workload, :in => 1..100, :message => "must be within 1 and 100 percent"
 
  before_destroy :check_if_last
  before_save :resolve_conflicts

  default_scope order(:start_date)

  scope :when, lambda { |date| { conditions: ['? >= start_date AND (? < end_date OR end_date IS NULL)', date, date ] } }
  scope :between, lambda { |starts, ends| { conditions: ['start_date < ? AND (end_date > ? OR end_date IS NULL)', ends, starts] } }
  
  def self.default
    Employment.new({
      start_date: Time.zone.now.beginning_of_year.to_date,
      workload: 100
    })
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
