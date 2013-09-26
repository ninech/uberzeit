require 'spec_helper'

describe GeneratePlannedWorkingTimesForUserAndYear do

  let(:user) { FactoryGirl.create(:user) }
  let(:year) { 2013 }

  subject { GeneratePlannedWorkingTimesForUserAndYear.new(user, year) }

  it 'returns true' do
    subject.run.should eq(true)
  end

  before do
    FactoryGirl.create(:public_holiday,
                       date: '2013-08-01',
                       name: 'Erschte Auguscht',
                       first_half_day: true, second_half_day: true)

    FactoryGirl.create(:public_holiday,
                       date: '2013-12-24',
                       name: 'Christmas',
                       first_half_day: false, second_half_day: true)

    FactoryGirl.create(:public_holiday,
                       date: '2014-01-01',
                       name: 'New Year',
                       first_half_day: false, second_half_day: true)
  end

  it 'calculates the planned working_time for all days of a given year' do
    expect { subject.run }.to change(Day, :count)
  end

  it 'calculates the correct planned working_time for the holidays of a given year' do
    subject.run
    user.days.find_by_date('2013-08-01').planned_working_time.should eq(0)
    user.days.find_by_date('2013-12-24').planned_working_time.should eq(4.25.hours)
  end

  it 'replaces the existing entries' do
    subject.run
    expect { subject.run }.to_not change(Day, :count)
  end

  it 'does not remove the other years' do
    employment = user.employments.first
    employment.end_date = nil
    employment.save!
    subject.run
    GeneratePlannedWorkingTimesForUserAndYear.new(user, year + 1).run
    Day.count.should eq(365 + 365)
  end
end
