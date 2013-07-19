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

require 'spec_helper'

describe Team do
  it 'has a valid factory' do
    FactoryGirl.create(:team).should be_valid
  end

  it 'returns if a specified user is member of this team' do
    team = FactoryGirl.create(:team, users_count: 2)
    team.has_member?(team.members.first).should be_true
    team.has_member?(team.members.second).should be_true
  end

  it 'acts as an enumerable' do
    team = FactoryGirl.create(:team, users_count: 2, leaders_count: 1)
    team.collect(&:id).length.should eq(3)
  end
end
