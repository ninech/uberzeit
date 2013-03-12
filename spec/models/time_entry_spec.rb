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

  it 'makes sure that the end time is after the start time' do
    time = '2013-01-01 8:00:00 UTC'.to_time
    FactoryGirl.build(:time_entry, start_time: time, end_time: time).should_not be_valid
  end

  it 'saves the times rounded' do
    rounded = UberZeit::Config[:rounding]/1.minute
    time = "2013-01-01 9:#{rounded-1}:00 UTC".to_time
    entry = FactoryGirl.create(:time_entry, start_time: time, duration: 2.hours)
    entry.starts.min.should eq(rounded)
  end

  it 'returns the duration' do
    time = '2013-01-01 8:00:00 UTC'.to_time
    entry = FactoryGirl.create(:time_entry, start_time: time, duration: 1.5.hours)
    entry.duration.should eq(1.5.hours)
  end

  context 'for multiple entries' do
    before do
      @entry1 = FactoryGirl.create(:time_entry, time_type: :work, start_time: '2013-01-23 9:00:00 UTC', end_time: '2013-01-23 12:00:00 UTC')
      @entry2 = FactoryGirl.create(:time_entry, time_type: :break, start_time: '2013-01-23 12:00:00 UTC', end_time: '2013-01-23 12:30:00 UTC')
      @entry3 = FactoryGirl.create(:time_entry, time_type: :work, start_time: '2013-01-23 12:30:00 UTC', end_time: '2013-01-24 00:00:00 UTC')
      @entry4 = FactoryGirl.create(:time_entry, time_type: :work, start_time: '2013-01-24 9:30:00 UTC', end_time: '2013-01-24 12:30:00 UTC')
    end

    it 'returns entries between two dates' do
      TimeEntry.between('2013-01-23'.to_date..'2013-01-30'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
      TimeEntry.between('2013-01-23'.to_date..'2013-01-24'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
      TimeEntry.between('2013-01-24'.to_date..'2013-01-27'.to_date).should =~ [@entry3,@entry4]
      TimeEntry.between('2013-01-25'.to_date..'2013-01-26'.to_date).should =~ []
    end

    it 'returns entries between two times (and respects the time-zone)' do
      zone_before = Time.zone
      Time.zone = 'Athens' # GMT + 2
      TimeEntry.between(Time.zone.parse('2013-01-24 00:00:00')..Time.zone.parse('2013-01-24 11:30:00')).should =~ [@entry3]
      TimeEntry.between(Time.zone.parse('2013-01-24 02:00:00')..Time.zone.parse('2013-01-25 02:00:00')).should =~ [@entry4]
      TimeEntry.between(Time.zone.parse('2013-01-25 00:00:00')..Time.zone.parse('2013-01-26 12:00:00')).should =~ []
      TimeEntry.between(Time.zone.parse('2013-01-24 01:00:00')..Time.zone.parse('2013-01-27 12:00:00')).should =~ [@entry3,@entry4]
      Time.zone = zone_before
    end
  end
end
