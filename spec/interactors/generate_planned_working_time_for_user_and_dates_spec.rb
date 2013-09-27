require 'spec_helper'

describe GeneratePlannedWorkingTimeForUserAndDates do

  let(:user) { FactoryGirl.create(:user) }
  let(:dates) { Date.civil(2013, 12, 23)..Date.civil(2013, 12, 24) }

  subject { GeneratePlannedWorkingTimeForUserAndDates.new(user, dates) }

  context 'date range' do
    it 'calculates all the planned working time of the given range' do
      expect { subject.run }.to change(Day, :count).from(0).to(2)
    end

    it 'calculates the correct planned working_time for the holidays of a given year' do
      subject.run
      PublicHoliday.any_instance.stub(:update_days)
      FactoryGirl.create(:public_holiday,
                         date: '2013-12-24',
                         name: 'Christmas',
                         first_half_day: false, second_half_day: true)

      expect { subject.run }.to change { user.days.in(dates).collect(&:planned_working_time).inject(&:+) }.from(2.work_days).to(1.5.work_days)
    end
  end

  context 'single date' do
    let(:dates) { Date.civil(2013, 12, 24) }
    it 'calculate the planned working time for the given date' do
      expect { subject.run }.to change(Day, :count).from(0).to(1)
    end

    it 'calculates the correct planned working_time for the holidays' do
      subject.run
      PublicHoliday.any_instance.stub(:update_days)
      FactoryGirl.create(:public_holiday,
                         date: '2013-12-24',
                         name: 'Christmas',
                         first_half_day: false, second_half_day: true)

      expect { subject.run }.to change { user.days.in(dates).collect(&:planned_working_time).inject(&:+) }.from(1.work_days).to(0.5.work_days)
    end
  end

end
