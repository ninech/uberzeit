require 'spec_helper'

describe GeneratePlannedWorkingTimeForUserAndDate do

  let(:user) { FactoryGirl.create(:user) }
  let(:date) { Date.civil(2013, 12, 24) }

  subject { GeneratePlannedWorkingTimeForUserAndDate.new(user, date) }

  before do
    user.generate_planned_working_time_for_year!(2013)
    PublicHoliday.any_instance.stub(:update_days)
    FactoryGirl.create(:public_holiday,
                       date: '2013-12-24',
                       name: 'Christmas',
                       first_half_day: false, second_half_day: true)
  end

  it 'calculates the correct planned working_time for the holidays of a given year' do
    expect { subject.run }.to change { user.days.find_by_date(date).planned_working_time }
  end

end
