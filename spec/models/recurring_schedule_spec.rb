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
    it 'requires a valid repeat interval type' do
      FactoryGirl.build(:recurring_schedule, repeat_interval_type: nil).should_not be_valid
      FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'not_a_valid_type').should_not be_valid
      RecurringSchedule::REPEAT_INTERVAL_TYPES.each do |type|
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: type).should be_valid
      end
    end

    it 'requires an associated entry' do
      FactoryGirl.build(:recurring_schedule, enterable: nil).should_not be_valid
    end

    context 'requires intervals' do
      it 'for interval type: daily' do
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', daily_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', daily_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', daily_repeat_interval: 1).should be_valid
      end

      it 'for interval type: weekly' do
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'weekly', weekly_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'weekly', weekly_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'weekly', weekly_repeat_interval: 1).should be_valid
      end

      it 'for interval type: monthly' do
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', monthly_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', monthly_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', monthly_repeat_interval: 1).should be_valid
      end

      it 'for interval type: yearly' do
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'yearly', yearly_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'yearly', yearly_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'yearly', yearly_repeat_interval: 1).should be_valid
      end
    end

    context 'monthly repeats' do
      it 'requires the information whether to repeat it based on day of the month or day of the week' do
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', monthly_repeat_by: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', monthly_repeat_by: 'when_the_invoices_arrive').should_not be_valid
        RecurringSchedule::MONTHLY_REPEAT_BY_CONDITIONS.each do |condition|
          FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', monthly_repeat_by: condition).should be_valid
        end
      end
    end

    context 'ending condition' do
      it 'requires a valid ending condition' do
        FactoryGirl.build(:recurring_schedule, ends: nil).should_not be_valid
        FactoryGirl.build(:recurring_schedule, ends: 'on_doomsday').should_not be_valid
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

  context '::number_of_weekday_occurrence_in_month' do
    it 'returns X for the Xth occurrence of the weekday in the month' do
      RecurringSchedule.number_of_weekday_occurrence_in_month('2013-03-01'.to_date).should eq(1)
      RecurringSchedule.number_of_weekday_occurrence_in_month('2013-03-04'.to_date).should eq(1)
      RecurringSchedule.number_of_weekday_occurrence_in_month('2013-03-08'.to_date).should eq(2)
      RecurringSchedule.number_of_weekday_occurrence_in_month('2013-03-28'.to_date).should eq(4)
      RecurringSchedule.number_of_weekday_occurrence_in_month('2013-03-31'.to_date).should eq(5)
    end
  end

  context '#occurrences' do
    let(:date) { '2013-03-14'.to_date }
    let(:entry) { FactoryGirl.build(:date_entry, start_date: date, end_date: date) }

    it 'returns the occurrences as start times in correct time zone' do
      recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', enterable: entry)
      recurring_schedule.occurrences(date).each do |occurrence|
        occurrence.should be_kind_of(ActiveSupport::TimeWithZone)
      end
    end

    context 'with daily repeats' do
      it 'finds the occurrences for the specified interval' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', enterable: entry)
        recurring_schedule.occurrences(date.yesterday).should be_empty
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date.tomorrow).should_not be_empty
        recurring_schedule.occurrences(date + 42.days).should_not be_empty
      end
    end
    context 'with weekly repeats' do
      it 'finds the occurrences for the specified interval' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'weekly', enterable: entry, weekly_repeat_interval: 2)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date.tomorrow).should be_empty
        recurring_schedule.occurrences(date+1.week).should be_empty
        recurring_schedule.occurrences(date+2.weeks).should_not be_empty
      end
      it 'finds the occurrences only on the week days when those are explicitly set' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'weekly', enterable: entry, weekly_repeat_interval: 1, weekly_repeat_weekday: [1,3]) # wdays: monday and wednesday
        recurring_schedule.occurrences(date).should be_empty
        recurring_schedule.occurrences('2013-03-11'.to_date).should be_empty
        recurring_schedule.occurrences('2013-03-18'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-03-19'.to_date).should be_empty
        recurring_schedule.occurrences('2013-03-20'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-03-25'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-03-26'.to_date).should be_empty
        recurring_schedule.occurrences('2013-03-27'.to_date).should_not be_empty
      end
    end
    context 'with monthly repeats' do
      context 'when the day of the month is set (e.g. start date is 2013-03-14, repeat every 14th of month)' do
        let(:recurring_schedule) { FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', enterable: entry, monthly_repeat_interval: 1, monthly_repeat_by: 'day_of_month') }
        it 'finds the occurrences for the specified interval' do
          recurring_schedule.occurrences('2013-03-14'.to_date).should_not be_empty
          recurring_schedule.occurrences('2013-04-11'.to_date).should be_empty
          recurring_schedule.occurrences('2013-04-14'.to_date).should_not be_empty
        end
      end
      context 'when day of the week is set (e.g. start date is 2013-03-14, which is the thursday, then repeat every second thursday in month)' do
        let(:recurring_schedule) { FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'monthly', enterable: entry, monthly_repeat_interval: 1, monthly_repeat_by: 'day_of_week') }
        it 'finds the occurrences for the specified interval' do
          recurring_schedule.occurrences('2013-03-14'.to_date).should_not be_empty
          recurring_schedule.occurrences('2013-04-11'.to_date).should_not be_empty
          recurring_schedule.occurrences('2013-04-14'.to_date).should be_empty
        end
      end
    end
    context 'with yearly repeats' do
      it 'finds the occurrences for the specified interval' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'yearly', enterable: entry, yearly_repeat_interval: 1)
        recurring_schedule.occurrences(date - 1.year).should be_empty
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 1.month).should be_empty
        recurring_schedule.occurrences(date + 1.year).should_not be_empty
      end
    end
    context 'ending condition' do
      it 'ends never' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', enterable: entry, ends: 'never')
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 42.years).should_not be_empty
      end
      it 'ends after a certain number of occurrences' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', enterable: entry, ends: 'counter', ends_counter: 3)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences(date + 1.day).should_not be_empty
        recurring_schedule.occurrences(date + 2.day).should_not be_empty
        recurring_schedule.occurrences(date + 3.day).should be_empty
      end
      it 'ends on a specific date' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', enterable: entry, ends: 'date', ends_date: '2013-07-20'.to_date)
        recurring_schedule.occurrences(date).should_not be_empty
        recurring_schedule.occurrences('2013-07-20'.to_date).should_not be_empty
        recurring_schedule.occurrences('2013-07-21'.to_date).should be_empty
      end
    end
    context '#occurring?' do
      it 'returns a boolean indicating whether or not there are occurrences in the supplied date/range' do
        recurring_schedule = FactoryGirl.build(:recurring_schedule, repeat_interval_type: 'daily', enterable: entry, ends: 'never')
        recurring_schedule.occurring?(date.yesterday).should be_false
        recurring_schedule.occurring?(date).should be_true
        recurring_schedule.occurring?(date.tomorrow).should be_true
        recurring_schedule.occurring?(date.yesterday..date).should be_true
      end
    end
  end
end
