require 'spec_helper'

describe RecurringSchedule do

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
    entry = FactoryGirl.build(:time_entry)
    FactoryGirl.build(:recurring_schedule, enterable: entry).entry.should eq(entry)
  end

  context 'validates all the things!' do
    context 'requires intervals' do
      it 'for interval type: weekly' do
        FactoryGirl.build(:recurring_schedule, weekly_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, weekly_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:recurring_schedule, weekly_repeat_interval: 1).should be_valid
      end
    end

    context 'ending condition' do
      it 'requires a valid ending condition' do
        FactoryGirl.build(:recurring_schedule, ends: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, ends: 'doomsday').should_not be_valid
        RecurringSchedule::ENDING_CONDITIONS.each do |condition|
          FactoryGirl.build(:recurring_schedule, ends: condition).should be_valid
        end
      end

      it 'requires a valid counter when ending condition is set to counter' do
        FactoryGirl.build(:recurring_schedule, ends: 'counter', ends_counter: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, ends: 'counter', ends_counter: 0).should_not be_valid
        FactoryGirl.build(:recurring_schedule, ends: 'counter', ends_counter: 1).should be_valid
      end

      it 'requires a valid date when ending condition is set to date' do
        FactoryGirl.build(:recurring_schedule, ends: 'date', ends_date: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, ends: 'date', ends_date: '1000 B.C.').should_not be_valid
        FactoryGirl.build(:recurring_schedule, ends: 'date', ends_date: '2013-07-20').should be_valid
      end
    end
  end

  context '#occurrences' do
    let(:date) { '2013-03-14'.to_date }
    let(:entry) { FactoryGirl.build(:absence, start_date: date, end_date: date) }

    it 'returns the occurrences as start times with time zone support' do
      recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: entry)
      recurring_schedule.occurrences(date).each do |occurrence|
        occurrence.should be_kind_of(ActiveSupport::TimeWithZone)
      end
    end

    context 'time entries' do
      it 'returns the time independent of the daylight saving time' do
        time = Time.zone.parse('2013-01-20 08:00:00')
        time_entry = FactoryGirl.build(:time_entry, start_time: time, end_time: time + 2.hours)
        recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: time_entry, ends: 'date', ends_date: '2014-01-01')
        occurence_start_time = recurring_schedule.occurrences('2013-07-21'.to_date).first
        occurence_start_time.strftime('%X').should eq(time.strftime('%X'))
      end
    end

    context 'with weekly repeats' do
      it 'finds the occurrences for the specified interval' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 10, weekly_repeat_interval: 2)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date.tomorrow).should be_empty
        recurring_schedule.occurrences(date + 1.week).should be_empty
        recurring_schedule.occurrences(date + 2.weeks).should_not be_empty
      end

      it 'finds occurrences which span multiple days' do
        absence = FactoryGirl.build(:absence, start_date: date, end_date: date + 1.day)
        recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: absence, ends: 'counter', ends_counter: 1)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date.tomorrow).should_not be_empty
        recurring_schedule.occurrences(date + 2.days).should be_empty
      end
    end

    context 'exception dates' do
      it 'takes exception dates into account' do
        recurring_schedule = FactoryGirl.create(:recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 4, exception_dates: [date+1.week])
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 1.week).should be_empty
        recurring_schedule.occurrences(date + 2.weeks).should_not be_empty
      end

      it 'takes exception dates into account which fall into the middle for entries which span over multiple days' do
        absence = FactoryGirl.build(:absence, start_date: '2013-07-20', end_date: '2013-07-22')
        recurring_schedule = FactoryGirl.create(:recurring_schedule, enterable: absence, ends: 'counter', ends_counter: 10, exception_dates: ['2013-07-28'])
        recurring_schedule.occurrences('2013-07-20'.to_date).should_not be_empty

        recurring_schedule.occurrences('2013-07-27'.to_date).should be_empty
        recurring_schedule.occurrences('2013-07-28'.to_date).should be_empty
        recurring_schedule.occurrences('2013-07-29'.to_date).should be_empty

        recurring_schedule.occurrences('2013-08-03'.to_date).should_not be_empty
      end
    end

    context 'ending condition' do
      it 'ends after a certain number of occurrences' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 3)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 1.week).should_not be_empty
        recurring_schedule.occurrences(date + 2.weeks).should_not be_empty
        recurring_schedule.occurrences(date + 3.weeks).should be_empty
      end
      it 'ends on a specific date' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: entry, ends: 'date', ends_date: '2013-07-19'.to_date)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences('2013-07-11'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-07-18'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-07-25'.to_date).should be_empty
      end
    end
    context '#occurring?' do
      it 'returns a boolean indicating whether or not there are occurrences in the supplied date/range' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, enterable: entry, ends: 'counter', ends_counter: 10)
        recurring_schedule.occurring?(date - 1.week).should be_false
        recurring_schedule.occurring?(date).should be_true
        recurring_schedule.occurring?(date + 1.week).should be_true
        recurring_schedule.occurring?(date.yesterday..date).should be_true
      end
    end
  end
end
