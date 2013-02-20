class User < ActiveRecord::Base
  attr_accessible :ldap_id, :name

  has_many :memberships, :dependent => :destroy
  has_many :teams, :through => :memberships

  def subordinates
    # method chaining LIKE A BOSS
    teams.select{ |t| t.has_leader?(self) }.collect{ |t| t.members }.flatten.uniq
  end
end
