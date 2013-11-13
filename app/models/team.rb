# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  uid        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

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
    members.with_role(:team_leader, self)
  end

  def each
    members.each { |user| yield(user) }
  end

  def to_s
    name
  end
end
