require 'spec_helper'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  it 'provides subordinates' do
    leader = FactoryGirl.create(:leader)
    leader.subordinates.length.should eq(leader.teams.first.members.length)
  end

  it 'acts as paranoid' do
    user = FactoryGirl.create(:user)
    user.destroy
    expect { User.find(user.id) }.to raise_error
    expect { User.with_deleted.find(user.id) }.to_not raise_error
  end

  it 'ensures that at least one time sheet exists' do
    user = FactoryGirl.create(:user, with_sheet: false)
    2.times { user.ensure_timesheet_and_employment_exist }
    user.time_sheets.count.should eq(1)
  end

  it 'ensures that at least one employment exists' do
    user = FactoryGirl.create(:user, with_employment: false)
    2.times { user.ensure_timesheet_and_employment_exist }
    user.time_sheets.count.should eq(1)
  end

end
