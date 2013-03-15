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

  it 'tells you whether or not it\'s a whole day entry' do
    entry = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04')
    entry.whole_day?.should be_true

    entry = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', second_half_day: true)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: true)
    entry.whole_day?.should be_true
  end

  # it 'provides the ability to convert the entries to chunks' do
  #   entry = FactoryGirl.create(:date_entry, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true)
  #   chunks = DateEntry.between('2013-01-03'.to_date..'2013-01-03'.to_date).to_chunks
  #   chunks.length.should eq(2)
  #   chunks.first.duration.should eq(12.hours)
  # end
  #

  describe '#daypart' do
    let(:date_entry) { DateEntry.new }
    it 'allows setting a whole day' do
      date_entry.daypart = :whole_day
      date_entry.whole_day?.should be_true
      date_entry.first_half_day?.should be_false
      date_entry.second_half_day?.should be_false
      date_entry.daypart.should eq(:whole_day)
    end
    it 'allows setting the first half of a day' do
      date_entry.daypart = :first_half_day
      date_entry.whole_day?.should be_false
      date_entry.first_half_day?.should be_true
      date_entry.second_half_day?.should be_false
      date_entry.daypart.should eq(:first_half_day)
    end
    it 'allows setting the second half of a day' do
      date_entry.daypart = :second_half_day
      date_entry.whole_day?.should be_false
      date_entry.first_half_day?.should be_false
      date_entry.second_half_day?.should be_true
      date_entry.daypart.should eq(:second_half_day)
    end
  end

  context 'for multiple entries' do
    before do
      @entry1 = FactoryGirl.create(:date_entry, time_type: :work, start_date: '2013-01-23', end_date: '2013-01-30', first_half_day: true)
      @entry2 = FactoryGirl.create(:date_entry, time_type: :break, start_date: '2013-01-23', end_date: '2013-01-23')
      @entry3 = FactoryGirl.create(:date_entry, time_type: :work, start_date: '2013-01-23', end_date: '2013-01-24', second_half_day: true)
      @entry4 = FactoryGirl.create(:date_entry, time_type: :work, start_date: '2013-01-24', end_date: '2013-01-24')
    end

    # it 'returns entries between two dates' do
    #   DateEntry.between('2013-01-23'.to_date..'2013-01-30'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
    #   DateEntry.between('2013-01-23'.to_date..'2013-01-24'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
    #   DateEntry.between('2013-01-24'.to_date..'2013-01-27'.to_date).should =~ [@entry1,@entry3,@entry4]
    #   DateEntry.between('2013-01-25'.to_date..'2013-01-26'.to_date).should =~ [@entry1]
    # end
  end
end
