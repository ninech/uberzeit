# == Schema Information
#
# Table name: absence_schedules
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(FALSE)
#  absence_id             :integer
#  ends                   :string(255)
#  ends_counter           :integer
#  ends_date              :date
#  weekly_repeat_interval :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

require 'spec_helper'

describe AbsenceSchedule do

  let(:date) { '2013-03-14'.to_date }
  let(:absence) { FactoryGirl.build(:absence, start_date: date, end_date: date) }

  it 'has a valid factory' do
    FactoryGirl.build(:absence_schedule).should be_valid
  end

  it 'acts as paranoid' do
    absence_schedule = FactoryGirl.create(:absence_schedule)
    absence_schedule.destroy
    expect { AbsenceSchedule.find(absence_schedule.id) }.to raise_error
    expect { AbsenceSchedule.with_deleted.find(absence_schedule.id) }.to_not raise_error
  end

  it 'tells you if it\'s active or not' do
    FactoryGirl.build(:absence_schedule, active: nil).active?.should be_false
    FactoryGirl.build(:absence_schedule, active: false).active?.should be_false
    FactoryGirl.build(:absence_schedule, active: true).active?.should be_true
  end

  it 'returns the absence it is associated to' do
    absence = FactoryGirl.build(:absence)
    FactoryGirl.build(:absence_schedule, :active, absence: absence).absence.should eq(absence)
  end

  context 'validates all the things!' do
    context 'requires intervals' do
      it 'for interval type: weekly' do
        FactoryGirl.build(:absence_schedule, :active, weekly_repeat_interval: nil).should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, weekly_repeat_interval: 0).should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, weekly_repeat_interval: 1).should be_valid
      end
    end

    context 'ending condition' do
      it 'requires a valid ending condition' do
        FactoryGirl.build(:absence_schedule, :active, ends: nil).should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, ends: 'doomsday').should_not be_valid
        AbsenceSchedule::ENDING_CONDITIONS.each do |condition|
          FactoryGirl.build(:absence_schedule, :active, ends: condition).should be_valid
        end
      end

      it 'requires a valid counter when ending condition is set to counter' do
        FactoryGirl.build(:absence_schedule, :active, ends: 'counter', ends_counter: nil).should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, ends: 'counter', ends_counter: 0).should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, ends: 'counter', ends_counter: 1).should be_valid
      end

      it 'requires a valid date when ending condition is set to date' do
        Timecop.travel('2013-05-01')
        FactoryGirl.build(:absence_schedule, :active, ends: 'date', ends_date: nil).should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, ends: 'date', ends_date: '1000 B.C.').should_not be_valid
        FactoryGirl.build(:absence_schedule, :active, ends: 'date', ends_date: '2013-07-20').should be_valid
      end

      it 'enforces that the end date is on or after the end date of the associated absence'  do
        FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'date', ends_date: absence.end_date - 1.day).should_not be_valid
      end
    end
  end

  context '#occurrences' do

    it 'ignores the repeating character of an absence when the ends date is BEFORE the end date of the absence' do
      absence_schedule = FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'date', ends_date: absence.end_date - 42.days)

      occurrences = absence_schedule.occurrences('2013-01-01'.to_date..'2013-12-31'.to_date)
      occurrences.should eq([absence.end_date])
    end

    context 'with weekly repeats' do
      it 'finds the occurrences for the specified interval' do
        absence_schedule = FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'counter', ends_counter: 10, weekly_repeat_interval: 2)
        absence_schedule.occurrences(date).should_not be_empty
        absence_schedule.occurrences(date.tomorrow).should be_empty
        absence_schedule.occurrences(date + 1.week).should be_empty
        absence_schedule.occurrences(date + 2.weeks).should_not be_empty
      end

      it 'finds occurrences which span multiple days' do
        absence = FactoryGirl.build(:absence, start_date: date, end_date: date + 1.day)
        absence_schedule = FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'counter', ends_counter: 1)
        absence_schedule.occurrences(date).should_not be_empty
        absence_schedule.occurrences(date.tomorrow).should_not be_empty
        absence_schedule.occurrences(date + 2.days).should be_empty
      end
    end

    context 'ending condition' do
      it 'ends after a certain number of occurrences' do
        absence_schedule = FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'counter', ends_counter: 3)
        absence_schedule.occurrences(date).should_not be_empty
        absence_schedule.occurrences(date + 1.week).should_not be_empty
        absence_schedule.occurrences(date + 2.weeks).should_not be_empty
        absence_schedule.occurrences(date + 3.weeks).should be_empty
      end
      it 'ends on a specific date' do
        absence_schedule = FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'date', ends_date: '2013-07-19'.to_date)
        absence_schedule.occurrences(date).should_not be_empty
        absence_schedule.occurrences('2013-07-11'.to_date).should_not be_empty
        absence_schedule.occurrences('2013-07-18'.to_date).should_not be_empty
        absence_schedule.occurrences('2013-07-25'.to_date).should be_empty
      end
    end
    context '#occurring?' do
      it 'returns a boolean indicating whether or not there are occurrences in the supplied date/range' do
        absence_schedule = FactoryGirl.build(:absence_schedule, :active, absence: absence, ends: 'counter', ends_counter: 10)
        absence_schedule.occurring?(date - 1.week).should be_false
        absence_schedule.occurring?(date).should be_true
        absence_schedule.occurring?(date + 1.week).should be_true
        absence_schedule.occurring?(date.yesterday..date).should be_true
      end
    end
  end
end
