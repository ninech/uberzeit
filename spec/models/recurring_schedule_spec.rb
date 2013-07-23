# == Schema Information
#
# Table name: recurring_schedules
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(FALSE)
#  enterable_id           :integer
#  enterable_type         :string(255)
#  ends                   :string(255)
#  ends_counter           :integer
#  ends_date              :date
#  weekly_repeat_interval :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

require 'spec_helper'

describe RecurringSchedule do

  let(:date) { '2013-03-14'.to_date }
  let(:entry) { FactoryGirl.build(:absence, start_date: date, end_date: date) }

  it 'has a valid factory' do
    FactoryGirl.build(:recurring_schedule).should be_valid
  end

  it 'acts as paranoid' do
    recurring_schedule = FactoryGirl.create(:recurring_schedule)
    recurring_schedule.destroy
    expect { RecurringSchedule.find(recurring_schedule.id) }.to raise_error
    expect { RecurringSchedule.with_deleted.find(recurring_schedule.id) }.to_not raise_error
  end

  it 'tells you if it\'s active or not' do
    FactoryGirl.build(:recurring_schedule, active: nil).active?.should be_false
    FactoryGirl.build(:recurring_schedule, active: false).active?.should be_false
    FactoryGirl.build(:recurring_schedule, active: true).active?.should be_true
  end

  it 'returns the entry it is associated to' do
    entry = FactoryGirl.build(:absence)
    FactoryGirl.build(:active_recurring_schedule, enterable: entry).entry.should eq(entry)
  end

  context 'validates all the things!' do
    context 'requires intervals' do
      it 'for interval type: weekly' do
        FactoryGirl.build(:active_recurring_schedule, weekly_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, weekly_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, weekly_repeat_interval: 1).should be_valid
      end
    end

    context 'ending condition' do
      it 'requires a valid ending condition' do
        FactoryGirl.build(:active_recurring_schedule, ends: nil).should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, ends: 'doomsday').should_not be_valid
        RecurringSchedule::ENDING_CONDITIONS.each do |condition|
          FactoryGirl.build(:active_recurring_schedule, ends: condition).should be_valid
        end
      end

      it 'requires a valid counter when ending condition is set to counter' do
        FactoryGirl.build(:active_recurring_schedule, ends: 'counter', ends_counter: nil).should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, ends: 'counter', ends_counter: 0).should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, ends: 'counter', ends_counter: 1).should be_valid
      end

      it 'requires a valid date when ending condition is set to date' do
        Timecop.travel('2013-05-01')
        FactoryGirl.build(:active_recurring_schedule, ends: 'date', ends_date: nil).should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, ends: 'date', ends_date: '1000 B.C.').should_not be_valid
        FactoryGirl.build(:active_recurring_schedule, ends: 'date', ends_date: '2013-07-20').should be_valid
      end

      it 'enforces that the end date is on or after the end date of the associated entry'  do
        FactoryGirl.build(:active_recurring_schedule, enterable: entry, ends: 'date', ends_date: entry.end_date - 1.day).should_not be_valid
      end
    end
  end

  context '#occurrences' do

    it 'ignores the repeating character of an entry when the ends date is BEFORE the end date of the absence' do
      recurring_schedule = FactoryGirl.build(:active_recurring_schedule, enterable: entry, ends: 'date', ends_date: entry.end_date - 42.days)

      occurrences = recurring_schedule.occurrences('2013-01-01'.to_date..'2013-12-31'.to_date)
      occurrences.should eq([entry.end_date])
    end

    context 'with weekly repeats' do
      it 'finds the occurrences for the specified interval' do
        recurring_schedule = FactoryGirl.build(:active_recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 10, weekly_repeat_interval: 2)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date.tomorrow).should be_empty
        recurring_schedule.occurrences(date + 1.week).should be_empty
        recurring_schedule.occurrences(date + 2.weeks).should_not be_empty
      end

      it 'finds occurrences which span multiple days' do
        absence = FactoryGirl.build(:absence, start_date: date, end_date: date + 1.day)
        recurring_schedule = FactoryGirl.build(:active_recurring_schedule, enterable: absence, ends: 'counter', ends_counter: 1)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date.tomorrow).should_not be_empty
        recurring_schedule.occurrences(date + 2.days).should be_empty
      end
    end

    context 'exception dates' do
      it 'takes exception dates into account' do
        recurring_schedule = FactoryGirl.create(:active_recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 4, exception_dates: [date+1.week])
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 1.week).should be_empty
        recurring_schedule.occurrences(date + 2.weeks).should_not be_empty
      end

      it 'takes exception dates into account which fall into the middle for entries which span over multiple days' do
        absence = FactoryGirl.build(:absence, start_date: '2013-07-20', end_date: '2013-07-22')
        recurring_schedule = FactoryGirl.create(:active_recurring_schedule, enterable: absence, ends: 'counter', ends_counter: 10, exception_dates: ['2013-07-28'])
        recurring_schedule.occurrences('2013-07-20'.to_date).should_not be_empty

        recurring_schedule.occurrences('2013-07-27'.to_date).should be_empty
        recurring_schedule.occurrences('2013-07-28'.to_date).should be_empty
        recurring_schedule.occurrences('2013-07-29'.to_date).should be_empty

        recurring_schedule.occurrences('2013-08-03'.to_date).should_not be_empty
      end
    end

    context 'ending condition' do
      it 'ends after a certain number of occurrences' do
        recurring_schedule = FactoryGirl.build(:active_recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 3)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 1.week).should_not be_empty
        recurring_schedule.occurrences(date + 2.weeks).should_not be_empty
        recurring_schedule.occurrences(date + 3.weeks).should be_empty
      end
      it 'ends on a specific date' do
        recurring_schedule = FactoryGirl.build(:active_recurring_schedule, enterable: entry, ends: 'date', ends_date: '2013-07-19'.to_date)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences('2013-07-11'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-07-18'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-07-25'.to_date).should be_empty
      end
    end
    context '#occurring?' do
      it 'returns a boolean indicating whether or not there are occurrences in the supplied date/range' do
        recurring_schedule = FactoryGirl.build(:active_recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 10)
        recurring_schedule.occurring?(date - 1.week).should be_false
        recurring_schedule.occurring?(date).should be_true
        recurring_schedule.occurring?(date + 1.week).should be_true
        recurring_schedule.occurring?(date.yesterday..date).should be_true
      end
    end
  end
end
