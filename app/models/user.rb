class User < ActiveRecord::Base
  rolify
  acts_as_paranoid

  default_scope order(:name)

  attr_accessible :uid, :name, :time_zone, :birthday, :given_name

  before_save :set_default_time_zone

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :time_sheets
  has_many :employments

  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.zones_map { |m| m.name }, :message => "is not a valid Time Zone"

  before_validation :set_default_time_zone

  def subordinates
    # method chaining LIKE A BOSS
    teams.select{ |t| t.has_leader?(self) }.collect{ |t| t.members }.flatten.uniq
  end

  def create_time_sheet_if_needed
    time_sheets.create! if time_sheets.empty?
  end

  def create_employment_if_needed
    employments.create! if employments.empty?
  end

  def ensure_timesheet_and_employment_exist
    create_time_sheet_if_needed
    create_employment_if_needed
    self
  end

  def workload_on(date)
    employment = self.employments.on(date)
    employment ? employment.workload : 0
  end

  def current_time_sheet
    time_sheets.first
  end

  def current_employment
    employments.first
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.name = auth['info']['name'] if auth['info']
    end
  end

  def to_s
    display_name
  end

  def display_name
    "#{given_name} #{name}"
  end

  private

  def set_default_time_zone
    self.time_zone ||= Time.zone.name
  end
end
