class User < ActiveRecord::Base
  rolify
  acts_as_paranoid

  default_scope order('users.name')

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
    Team.with_role(:team_leader, self).collect(&:members).flatten.uniq
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
    ensure_timesheet_and_employment_exist
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
    [name, given_name].compact.join(', ')
  end

  def team_leader?
    Team.with_role(:team_leader, self).any?
  end

  def admin?
    has_role?(:admin)
  end

  private

  def set_default_time_zone
    self.time_zone ||= Time.zone.name
  end
end
