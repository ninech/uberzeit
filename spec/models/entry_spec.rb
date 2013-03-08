require 'spec_helper'

describe Entry do
  context 'for multi-entry time sheet' do
    before do
      @entry1 = FactoryGirl.create(:time_entry, type: :work, start_time: '2013-01-23 9:00:00 UTC', end_time: '2013-01-23 12:00:00 UTC')
      @entry2 = FactoryGirl.create(:time_entry, type: :break, start_time: '2013-01-23 12:00:00 UTC', end_time: '2013-01-23 12:30:00 UTC')
      @entry3 = FactoryGirl.create(:time_entry, type: :work, start_time: '2013-01-23 12:30:00 UTC', end_time: '2013-01-24 00:00:00 UTC')
      @entry4 = FactoryGirl.create(:time_entry, type: :work, start_time: '2013-01-24 9:30:00 UTC', end_time: '2013-01-24 12:30:00 UTC')
      @entry5 = FactoryGirl.create(:date_entry, type: :vacation, start_date: '2013-01-25', end_date: '2013-01-25')
    end

    it 'finds chunks between two dates' do
      chunks = Entry.find_chunks('2013-01-23'.to_date..'2013-01-24'.to_date, :work)
      chunks.collect { |chunk| chunk.parent }.should =~ [@entry1,@entry3,@entry4]
    end

    it 'finds chunks for a date' do
      chunks = Entry.find_chunks('2013-01-25'.to_date, :vacation)
      chunks.collect{ |chunk| chunk.parent }.should =~ [@entry5]
    end
  end
end
