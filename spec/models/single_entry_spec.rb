require 'spec_helper'

describe SingleEntry do
  it 'has a valid factory' do
    FactoryGirl.create(:single_entry).should be_valid
  end 
  
  it 'acts as paranoid' do
    entry = FactoryGirl.create(:single_entry)
    entry.destroy
    expect { SingleEntry.find(entry.id) }.to raise_error
    expect { SingleEntry.with_deleted.find(entry.id) }.to_not raise_error
  end

  it 'makes sure that the end time is after the start time' do
    time = '2013-01-01 8:00:00 UTC'.to_time
    FactoryGirl.build(:single_entry, start_time: time, end_time: time).should_not be_valid
  end

  it 'saves the times rounded' do
    rounded = UberZeit::Config[:rounding]/1.minute
    time = "2013-01-01 9:#{rounded-1}:00 UTC".to_time
    entry = FactoryGirl.create(:single_entry, start_time: time, duration: 2.hours)
    entry.starts.min.should eq(rounded)
  end

  it 'returns the duration' do
    time = '2013-01-01 8:00:00 UTC'.to_time
    entry = FactoryGirl.create(:single_entry, start_time: time, duration: 1.5.hours)
    entry.duration.should eq(1.5.hours)
  end

  context 'for multi-entry time sheet' do
    before do
      @sheet = FactoryGirl.create(:time_sheet)
      # create tricky scheme
      @entry1 = FactoryGirl.create(:single_entry, type: :work, start_time: '2013-01-23 9:00:00 UTC', end_time: '2013-01-23 12:00:00 UTC')
      @entry2 = FactoryGirl.create(:single_entry, type: :break, start_time: '2013-01-23 12:00:00 UTC', end_time: '2013-01-23 12:30:00 UTC')
      @entry3 = FactoryGirl.create(:single_entry, type: :work, start_time: '2013-01-23 12:30:00 UTC', end_time: '2013-01-24 00:00:00 UTC')
      @entry4 = FactoryGirl.create(:single_entry, type: :work, start_time: '2013-01-24 9:30:00 UTC', end_time: '2013-01-24 12:30:00 UTC')
      @entry5 = FactoryGirl.create(:single_entry, type: :vacation, start_time: '2013-01-25 01:00:00 GMT+1', end_time: '2013-01-26 01:00:00 GMT+1', whole_day: true)
      @sheet.single_entries += [@entry1, @entry2, @entry3, @entry4, @entry5]
    end

    # scope between
    it 'returns entries between two dates' do
      @sheet.single_entries.between('2013-01-23'.to_date, '2013-01-30'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4,@entry5]
      @sheet.single_entries.between('2013-01-23'.to_date, '2013-01-24'.to_date).should =~ [@entry1,@entry2,@entry3]
      @sheet.single_entries.between('2013-01-24'.to_date, '2013-01-27'.to_date).should =~ [@entry3,@entry4,@entry5]
      @sheet.single_entries.between('2013-01-25'.to_date, '2013-01-26'.to_date).should =~ [@entry5]
    end

    it 'returns entries between two times (and respects the time-zone)' do
      @sheet.single_entries.between('2013-01-24 00:00:00 GMT+2'.to_time, '2013-01-24 11:00:00 GMT+2'.to_time).should =~ [@entry3]
      @sheet.single_entries.between('2013-01-24 02:00:00 GMT+2'.to_time, '2013-01-25 02:00:00 GMT+2'.to_time).should =~ [@entry4]
      @sheet.single_entries.between('2013-01-25 00:00:00 GMT+2'.to_time, '2013-01-26 12:00:00 GMT+2'.to_time).should =~ [@entry5]
      @sheet.single_entries.between('2013-01-24 01:00:00 GMT+2'.to_time, '2013-01-27 12:00:00 GMT+2'.to_time).should =~ [@entry3,@entry4,@entry5]
    end

    it 'finds chunks between two dates' do
      chunks = @sheet.single_entries.find_chunks('2013-01-23'.to_date..'2013-01-24'.to_date, :work)
      chunks.length.should eq(2)
      chunks.first.parent.should eq(@entry1)
      chunks.second.parent.should eq(@entry3)
    end

    it 'finds chunks for a date' do
      chunks = @sheet.single_entries.find_chunks('2013-01-25'.to_date, :vacation)
      chunks.length.should eq(1)
      chunks.first.parent.should eq(@entry5)
    end
  end

  context 'for whole day entries' do
    it 'sets start-time and end-time to utc time ignoring time zone when whole day is set' do
      entry = FactoryGirl.create(:single_entry, type: :vacation, start_time: '2013-01-25 00:00:00 GMT+1', whole_day: true)
      entry.send(:start_time).should eq('2013-01-25 00:00:00 UTC'.to_time)
    end

    it 'returns start and end respecting the time zone' do
      entry = FactoryGirl.create(:single_entry, type: :vacation, start_time: '2013-01-25 00:00:00 GMT+1', whole_day: true)
      entry.starts.should eq('2013-01-25 00:00:00 GMT+1'.to_time)
    end

    it 'makes sure that end date can match start date (end date is inclusive)' do
      entry = FactoryGirl.build(:single_entry, start_time: '2013-01-24 00:00:00 GMT+1', end_time: '2013-01-24 00:00:00 GMT+1', whole_day: true )
      entry.should be_valid
    end
  end
end