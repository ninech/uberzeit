# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  uid                  :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  deleted_at           :datetime
#  time_zone            :string(255)
#  given_name           :string(255)
#  birthday             :date
#  authentication_token :string(255)
#

class User < ActiveRecord::Base
  include TokenAuthenticable

  rolify
  acts_as_paranoid

  default_scope order('users.name')

  attr_accessible :uid, :name, :time_zone, :birthday, :given_name

  before_save :set_default_time_zone

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :absences, dependent: :destroy
  has_many :adjustments, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :days, dependent: :destroy
  has_many :time_spans, dependent: :destroy

  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.zones_map { |m| m.name }, :message => "is not a valid Time Zone"

  before_validation :set_default_time_zone

  def subordinates
    # method chaining LIKE A BOSS
    Team.with_role(:team_leader, self).collect(&:members).flatten.uniq
  end

  def create_employment_if_needed
    employments.create! if employments.empty?
  end

  def ensure_employment_exists
    create_employment_if_needed
    self
  end

  def workload_on(date)
    employment = self.employments.on(date)
    employment ? employment.workload : 0
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

  def accountant?
    has_role?(:accountant)
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def timer
    time_entries.timers_only.first
  end

  def time_sheet
    @time_sheet ||= TimeSheet.new(self)
  end

  private
  def set_default_time_zone
    self.time_zone ||= Time.zone.name
  end
end
