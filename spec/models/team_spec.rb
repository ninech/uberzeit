require 'spec_helper'

describe Team do
  it 'has a valid factory' do
    FactoryGirl.create(:team).should be_valid
  end

  it 'returns if a specified user is member of this team' do
    team = FactoryGirl.create(:team, members_count: 2)
    team.has_member?(team.members.first).should be_true
    team.has_member?(team.members.second).should be_true
  end

  it 'acts as an enumerable' do
    team = FactoryGirl.create(:team, members_count: 2)
    team.collect { |user| user }.length.should eq(2)
  end
end
