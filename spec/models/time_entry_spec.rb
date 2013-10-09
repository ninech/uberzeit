# == Schema Information
#
# Table name: time_entries
#
#  id           :integer          not null, primary key
#  time_type_id :integer
#  starts       :datetime
#  ends         :datetime
#  deleted_at   :datetime
#  user_id      :integer
#

require 'spec_helper'

describe TimeEntry do
  it 'has a valid factory' do
    FactoryGirl.create(:time_entry).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:time_entry)
    entry.destroy
    expect { TimeEntry.find(entry.id) }.to raise_error
    expect { TimeEntry.with_deleted.find(entry.id) }.to_not raise_error
  end

  it 'returns the entries sorted by start time' do
    # create the newer entry first
    entry1 = FactoryGirl.create(:time_entry, starts: '2013-01-23 12:00:00 +0000', ends: '2013-01-23 13:00:00 +0000')
    entry2 = FactoryGirl.create(:time_entry, starts: '2013-01-23 9:00:00 +0000', ends: '2013-01-23 12:00:00 +0000')

    TimeEntry.all.should eq([entry2,entry1])
  end

  it 'makes sure that the end time is after the start time' do
    time = '2013-01-01 8:00:00 +0000'.to_time
    FactoryGirl.build(:time_entry, starts: time, ends: time).should_not be_valid
  end

  it 'saves the times rounded' do
    time = "2013-01-01 9:03:37 +0000".to_time
    rounded = "2013-01-01 9:04:00 +0000".to_time
    entry = FactoryGirl.create(:time_entry, starts: time, ends: time + 2.hours)
    entry.starts.should eq(rounded)
  end

  it 'returns the duration' do
    time = '2013-01-01 8:00:00 +0000'.to_time
    entry = FactoryGirl.create(:time_entry, starts: time, ends: time + 1.5.hours)
    entry.duration.should eq(1.5.hours)
  end

  describe 'timer' do
    let(:time_entry) { FactoryGirl.create(:time_entry, start_date: '2013-07-20', start_time: '08:00', end_date: '2013-07-20', end_time: '10:00') }

    it 'marks the time entry as a timer when the end time is set to empty' do
      expect {
        time_entry.end_time = ''
        time_entry.save!
      }.to change(time_entry, :timer?).from(false).to(true)
    end
  end

  context 'occurrences' do
    it 'respects the time zone' do
      entry = FactoryGirl.create(:time_entry, starts: '2013-01-23 9:00:00 +0000', ends: '2013-01-23 12:00:00 +0000')
      entry.occurrences_as_time_ranges('2013-01-23'.to_date).each do |occurrence_range|
        occurrence_range.min.should be_kind_of(ActiveSupport::TimeWithZone)
        occurrence_range.max.should be_kind_of(ActiveSupport::TimeWithZone)
      end
    end
  end

  context 'virtual attributes' do
    subject { TimeEntry.new }

    it 'allows setting the start time only' do
      Timecop.freeze('2013-05-20')
      subject.start_time = '9:00'
      subject.starts.should eq("2013-05-20 09:00:00 +0200".to_time)
    end

    it 'allows setting the start date only' do
      Timecop.freeze('2013-05-20 05:00:00 +0200')
      subject.start_date = '2013-04-13'
      subject.starts.should eq("2013-04-13 05:00:00 +0200".to_time)
    end

    it 'handles a blank start time' do
      subject.start_time = ''
      subject.end_time = '9:00'
      expect { subject.valid? }.to_not raise_error
    end

    it 'supports mass assignment' do
      Timecop.freeze('2013-05-20 05:00:00 +0200')
      time_entry = TimeEntry.new(start_date: '2013-04-12', start_time: '09:00')
      time_entry.starts.should eq("2013-04-12 09:00:00 +0200".to_time)
    end

    it 'validates a blank start_time' do
      time_entry = TimeEntry.new(start_time: '')
      time_entry.valid?
      time_entry.should have(1).errors_on(:start_time)
    end

    it 'validates a blank start_date' do
      time_entry = TimeEntry.new(start_date: '')
      time_entry.valid?
      time_entry.should have(1).errors_on(:start_date)
    end

    it 'sets the end date to the start date if end time is set and no end date was set' do
      Timecop.freeze('2013-07-22')
      time_entry = TimeEntry.new(start_date: '2013-07-20', start_time: '09:00', end_time: '12:00')
      time_entry.ends.should eq('2013-07-20 12:00:00 +0200'.to_time)
    end
  end

  context 'timer' do
    let(:timer) { FactoryGirl.build(:timer, start_date: '2013-04-12', start_time: '09:00') }

    subject { timer }

    it 'allows end to not be filled in' do
      subject.ends = nil
      subject.valid?
      subject.should have(:no).errors_on(:ends)
    end

    it 'supports range' do
      Timecop.freeze('2013-04-12 10:00:00 +0200')
      subject.ends = nil
      subject.range.should eq(('2013-04-12 09:00:00 +0200'.to_time)..('2013-04-12 10:00:00 +0200'.to_time))
    end

    it 'validates that only one timer runs on given date' do
      expect {
        FactoryGirl.create(:timer, start_date: '2013-04-12', start_time: '08:00', user: subject.user)
      }.to change(subject, :valid?).to(false)
    end
  end

  context 'denormalization' do
    context 'single day' do
      subject { FactoryGirl.build(:time_entry, start_date: '2013-01-01', start_time: '12:00:00', end_date: '2013-01-01', end_time: '13:00:00') }

      it 'creates a TimeSpan if it does not exist yet' do
        expect { subject.save! }.to change(TimeSpan, :count)
      end

      context 'changes' do
        before do
          subject.save!
        end

        it 'fills all the fields of TimeSpan' do
          subject.time_spans.first.duration.should eq(subject.duration)
          subject.time_spans.first.date.should eq(subject.start_date)
          subject.time_spans.first.user.should eq(subject.user)
          subject.time_spans.first.time_type.should eq(subject.time_type)
          subject.time_spans.first.duration_bonus.should eq(0)
        end

        it 'updates the TimeSpan' do
          subject.time_spans.first.duration.should eq(1.hours)
          subject.end_time = '14:00:00'
          subject.save!
          subject.time_spans.first.duration.should eq(2.hours)
        end

        it 'removes the TimeSpan when it gets destroyed' do
          expect { subject.destroy }.to change(TimeSpan, :count)
        end

        it 'creates a TimeSpan for only one date' do
          subject.time_spans.count.should eq(1)
        end

        it 'does not create timespans for timers' do
          subject.ends = nil
          expect { subject.save! }.to change(TimeSpan, :count)
        end
      end
    end

    context 'multiple days' do
      subject { FactoryGirl.build(:time_entry) }

      before do
        subject.starts = '2013-01-01 23:45:00'
        subject.ends = '2013-01-02 00:15:00'
        subject.save!
      end

      it 'creates a TimeSpan for each date in the range' do
        subject.time_spans.count.should eq(2)
      end

      it 'generates TimeSpans for each day of the range' do
        subject.time_spans.collect(&:date).map(&:to_s).should eq(%w[2013-01-01 2013-01-02])
      end

      it 'calculates the bonus' do
        time_type = FactoryGirl.create(:time_type_work)
        subject.time_type = time_type
        subject.save!
        
        UberZeit::BonusCalculators.register :nine_on_duty, UberZeit::BonusCalculators::NineOnDuty
        subject.time_type.bonus_calculator = 'nine_on_duty'
        subject.time_type.save!
        subject.time_spans.reload.collect(&:duration_bonus).inject(&:+).should > 0
      end
    end
  end
end
