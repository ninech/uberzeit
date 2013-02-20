require 'spec_helper'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  it 'provides subordinates' do
    leader = FactoryGirl.create(:leader)
    leader.subordinates.length.should eq(leader.teams.first.members.length)
  end
end
