require 'spec_helper'

describe DateEntry do
  it 'has a valid factory' do
    FactoryGirl.create(:date_entry).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:date_entry)
    entry.destroy
    expect { DateEntry.find(entry.id) }.to raise_error
    expect { DateEntry.with_deleted.find(entry.id) }.to_not raise_error
  end

  it 'makes sure that the end date is not before the start date' do
    entry = FactoryGirl.build(:date_entry, start_date: '2013-01-03', end_date: '2013-01-02')
    entry.should_not be_valid
  end

  it 'returns the duration' do
    entry = FactoryGirl.build(:date_entry, start_date: '2013-01-03', end_date: '2013-01-03')
    entry.duration.should eq(1.day)
  end

  context 'for multiple entries' do
    before do
      @entry1 = FactoryGirl.create(:date_entry, type: :work, start_date: '2013-01-23', end_date: '2013-01-23')
      @entry2 = FactoryGirl.create(:date_entry, type: :break, start_date: '2013-01-23', end_date: '2013-01-23')
      @entry3 = FactoryGirl.create(:date_entry, type: :work, start_date: '2013-01-23', end_date: '2013-01-24')
      @entry4 = FactoryGirl.create(:date_entry, type: :work, start_date: '2013-01-24', end_date: '2013-01-24')
    end

    it 'returns entries between two dates' do
      DateEntry.between('2013-01-23'.to_date..'2013-01-30'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
      DateEntry.between('2013-01-23'.to_date..'2013-01-24'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
      DateEntry.between('2013-01-24'.to_date..'2013-01-27'.to_date).should =~ [@entry3,@entry4]
      DateEntry.between('2013-01-25'.to_date..'2013-01-26'.to_date).should =~ []
    end
  end
end
