class Team < ActiveRecord::Base
  attr_accessible :ldap_id, :name

  has_many :memberships, :conditions => { :role => 'member' }, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :user

  has_many :leaderships, :class_name => 'Membership', :conditions => { :role => 'leader' }, :dependent => :destroy
  has_many :leaders, :through => :leaderships, :source => :user

  def has_leader?(user)
    leaders.include?(user)
  end

  def has_member?(user)
    members.include?(user)
  end
end
