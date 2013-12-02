# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  email                :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  deleted_at           :datetime
#  given_name           :string(255)
#  birthday             :date
#  authentication_token :string(255)
#
require 'bcrypt'

class User < ActiveRecord::Base
  include TokenAuthenticable

  rolify
  acts_as_paranoid
  validates_as_paranoid

  default_scope order('users.name')

  attr_accessible :email, :name, :birthday, :given_name, :team_ids, :password, :password_confirmation, :auth_source

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :absences, dependent: :destroy
  has_many :adjustments, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :days, dependent: :destroy
  has_many :time_spans, dependent: :destroy

  validates_uniqueness_of_without_deleted :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/ }

  validates_presence_of :given_name, :name

  validates_presence_of :password, on: :create, if: -> { auth_source.blank? }
  attr_reader :password
  validates_confirmation_of :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation

  scope :in_teams, ->(teams) { where Membership.where(team_id: teams).where('user_id = users.id').exists }

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

  def editable?
    auth_source.blank?
  end

  def with_editable(&block)
    block.call if editable?
  end
end
