# == Schema Information
#
# Table name: absences
#
#  id              :integer          not null, primary key
#  time_type_id    :integer
#  start_date      :date
#  end_date        :date
#  first_half_day  :boolean          default(TRUE)
#  second_half_day :boolean          default(TRUE)
#  deleted_at      :datetime
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Absence do
  it 'has a valid factory' do
    FactoryGirl.create(:absence).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:absence)
    entry.destroy
    expect { Absence.find(entry.id) }.to raise_error
    expect { Absence.with_deleted.find(entry.id) }.to_not raise_error
  end

  it 'makes sure that the end date is not before the start date' do
    entry = FactoryGirl.build(:absence, start_date: '2013-01-03', end_date: '2013-01-02')
    entry.should_not be_valid
  end

  it 'returns the duration' do
    entry = FactoryGirl.build(:absence, start_date: '2013-01-03', end_date: '2013-01-03')
    entry.duration.should eq(1.day)
  end

  it 'returns the entries sorted by start date' do
    # create the newer entry first
    entry1 = FactoryGirl.create(:absence, start_date: '2013-01-04', end_date: '2013-01-04')
    entry2 = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-03')

    Absence.all.should eq([entry2,entry1])
  end

  it 'tells you whether or not it\'s a whole day entry' do
    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04')
    entry.whole_day?.should be_true

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: false)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', second_half_day: false)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: true)
    entry.whole_day?.should be_true
  end

  describe '#daypart' do
    let(:absence) { Absence.new }
    it 'allows setting a whole day' do
      absence.daypart = :whole_day
      absence.whole_day?.should be_true
      absence.first_half_day?.should be_false
      absence.second_half_day?.should be_false
      absence.daypart.should eq(:whole_day)
    end
    it 'allows setting the first half of a day' do
      absence.daypart = :first_half_day
      absence.whole_day?.should be_false
      absence.first_half_day?.should be_true
      absence.second_half_day?.should be_false
      absence.daypart.should eq(:first_half_day)
    end
    it 'allows setting the second half of a day' do
      absence.daypart = :second_half_day
      absence.whole_day?.should be_false
      absence.first_half_day?.should be_false
      absence.second_half_day?.should be_true
      absence.daypart.should eq(:second_half_day)
    end
  end

  context 'denormalization' do
    context 'single day' do
      subject { FactoryGirl.build(:absence, start_date: '2013-01-01', end_date: '2013-01-01') }

      it 'creates a TimeSpan if it does not exist yet' do
        expect { subject.save! }.to change(TimeSpan, :count)
      end

      context 'changes' do
        before do
          subject.save!
        end

        it 'fills all the fields of TimeSpan' do
          subject.time_spans.first.duration_in_work_days.should eq(1)
          subject.time_spans.first.date.should eq(subject.start_date)
          subject.time_spans.first.user.should eq(subject.user)
          subject.time_spans.first.time_type.should eq(subject.time_type)
        end

        it 'updates the TimeSpan' do
          subject.time_spans.first.duration_in_work_days.should eq(1)
          subject.first_half_day = false
          subject.save!
          subject.time_spans.first.duration_in_work_days.should eq(0.5)
        end

        it 'recalculates the credited_duration' do
          subject.time_spans.first.credited_duration_in_work_days.should eq(1)
          subject.first_half_day = false
          subject.save!
          subject.time_spans.first.credited_duration_in_work_days.should eq(0.5)
        end

        it 'removes the TimeSpan when it gets destroyed' do
          expect { subject.destroy }.to change(TimeSpan, :count)
        end

        it 'creates a TimeSpan for only one date' do
          subject.time_spans.count.should eq(1)
        end

        context 'when TimeType should be excluded from calculation' do
          before do
            subject.time_type = TEST_TIME_TYPES[:compensation]
            subject.save!
          end

          it 'sets the credited duration to zero' do
            subject.time_spans.map(&:credited_duration_in_work_days).should eq([0])
          end

          it 'sets the duration to the planned working time on that day' do
            subject.time_spans.map(&:duration_in_work_days).should eq([1])
          end

          context 'on a non work day (e.g. weekend)' do
            before do
              subject.start_date = '2013-01-06' # sunday
              subject.end_date = '2013-01-06'
              subject.save!
            end

            it 'sets the duration to zero' do
              subject.time_spans.map(&:duration_in_work_days).should eq([0])
            end
          end
        end
      end
    end

    context 'multiple days' do
      subject { FactoryGirl.create(:absence, start_date: '2013-01-01', end_date: '2013-01-03') }

      it 'creates a TimeSpan for each date in the range' do
        subject.time_spans.count.should eq(3)
      end

      it 'generates TimeSpans for each day of the range' do
        subject.time_spans.collect(&:date).map(&:to_s).should eq(%w[2013-01-01 2013-01-02 2013-01-03])
      end

      it 'uses the planned work time to set the duration' do
        subject.start_date = '2013-09-27'
        subject.end_date = '2013-09-30'
        subject.save!
        subject.time_spans.collect(&:duration_in_work_days).sum.should eq(2)
        subject.time_spans.collect(&:credited_duration_in_work_days).sum.should eq(2)
      end
    end

    context 'recurring' do
      subject { FactoryGirl.create(:absence, start_date: '2013-10-02', end_date: '2013-10-02', schedule_attributes: {active: true, ends_date: '2013-10-09', weekly_repeat_interval: 1}) }

      it 'calculates time span for each recurring date' do
        subject.time_spans.collect(&:date).map(&:to_s).should eq(%w[2013-10-02 2013-10-09])
      end

      it 'reloads the schedule upon update' do
        subject.start_date = '2013-10-01'
        subject.save
        subject.time_spans.collect(&:date).map(&:to_s).should eq(%w[2013-10-01 2013-10-02 2013-10-08 2013-10-09])
      end
    end
  end

  describe 'overlapping validation' do
    let(:user) { FactoryGirl.create :user }

    context 'with simple absences' do
      subject { FactoryGirl.build(:absence, user: user, start_date: '2013-01-01', end_date: '2013-01-01') }

      context 'when not overlapping' do
        context 'with same user but different date' do
          let!(:other_absence) { FactoryGirl.create(:absence, user: user, start_date: '2013-01-02', end_date: '2013-01-02') }

          it { should be_valid }
        end

        context 'with different user but same date' do
          let!(:other_absence) { FactoryGirl.create(:absence, start_date: '2013-01-01', end_date: '2013-01-01') }

          it { should be_valid }
        end

        context 'when changing the absence' do
          before(:each) do
            subject.end_date = '2013-01-02'
            subject.save!
          end

          it { should be_valid }
        end
      end

      context 'when overlapping' do
        subject { FactoryGirl.build(:absence, user: user, start_date: '2013-01-01', end_date: '2013-01-01') }
        let!(:other_absence) { FactoryGirl.create(:absence, user: user, start_date: '2013-01-01', end_date: '2013-01-01') }

        it { should_not be_valid }
      end
    end

    context 'first / second half day' do
      subject { FactoryGirl.build(:absence, user: user, start_date: '2013-01-01', end_date: '2013-01-01', first_half_day: true, second_half_day: false) }

      context 'when not overlapping' do
        let!(:other_absence) { FactoryGirl.create(:absence, user: user, start_date: '2013-01-01', end_date: '2013-01-01', first_half_day: false, second_half_day: true) }

        it { should be_valid }
      end

      context 'when overlapping' do
        let!(:other_absence) { FactoryGirl.create(:absence, user: user, start_date: '2013-01-01', end_date: '2013-01-01', first_half_day: true, second_half_day: true) }

        it { should_not be_valid }
      end
    end

    context 'with scheduled absences' do
      let(:user) { FactoryGirl.create :user }
      subject { FactoryGirl.build(:absence, user: user, start_date: '2013-10-07', end_date: '2013-10-08', schedule_attributes: {active: true, ends_date: '2013-11-03', weekly_repeat_interval: 1}) }

      context 'when overlapping' do
        let!(:other_absence) { FactoryGirl.create(:absence, user: user, start_date: '2013-10-15', end_date: '2013-10-15', schedule_attributes: {active: true, ends_date: '2013-11-03', weekly_repeat_interval: 1}) }

        it { should_not be_valid }
      end
    end
  end
end
