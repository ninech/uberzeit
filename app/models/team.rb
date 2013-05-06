class Team < ActiveRecord::Base
  include Enumerable

  resourcify

  acts_as_paranoid

  attr_accessible :uid, :name

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, :source => :user

  def has_member?(user)
    members.include?(user)
  end

  def leaders
    members.select { |user| user.has_role?(:team_leader, self) }
  end

  def each
    members.each { |user| yield(user) }
  end
end
