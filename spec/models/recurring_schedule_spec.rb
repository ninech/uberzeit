require 'spec_helper'

describe RecurringSchedule do
  it 'has a valid factory' do
    FactoryGirl.create(:recurring_schedule).should be_valid
  end

  it 'acts as paranoid' do
    recurring_schedule = FactoryGirl.create(:recurring_schedule)
    recurring_schedule.destroy
    expect { RecurringSchedule.find(recurring_schedule.id) }.to raise_error
    expect { RecurringSchedule.with_deleted.find(recurring_schedule.id) }.to_not raise_error
  end
end
