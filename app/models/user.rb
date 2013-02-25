class User < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :ldap_id, :name

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :sheets, class_name: 'TimeSheet'
  has_many :employments

  def subordinates
    # method chaining LIKE A BOSS
    teams.select{ |t| t.has_leader?(self) }.collect{ |t| t.members }.flatten.uniq
  end

  def ensure_timesheet_and_employment_exist
    # ensure a valid timesheet and a employment entry exists
    self.sheets << TimeSheet.new if self.sheets.empty?
    self.employments << Employment.default if self.employments.empty?
    save! if changed?
  end
end
